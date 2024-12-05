% 必要なデータの読み込み (既存プログラムに基づく前処理が済んでいることを前提)

% 必要なデータの読み込み
cloud_file = '202407210729UTmodel_cloud.nc';
cape_file = '202407210729UTmodel_cape.nc';

% 比湿データ
q_data = ncread(cloud_file, 'q'); % 比湿データ
lat_q = ncread(cloud_file, 'latitude');
lon_q = ncread(cloud_file, 'longitude');

% CAPEデータ
cape_data = ncread(cape_file, 'cape');

% 風速データ（DLS計算用）
u_data = ncread(cloud_file, 'u'); % 東西風
v_data = ncread(cloud_file, 'v'); % 南北風

% 圧力レベル（DLS用）
level_500hpa_idx = 1; % 500 hPa
level_1000hpa_idx = 3; % 1000 hPa

% 時間軸設定
time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9); % JST
time_step = hours(1);
num_time_steps = size(q_data, 4);
time_axis = time_start + (0:num_time_steps-1) * time_step;

% 緯度・経度の範囲設定
lat_target = 39; % 中心緯度
lon_target = 140; % 中心経度
lat_range = [lat_target - 0.5, lat_target + 0.5];
lon_range = [lon_target - 0.5, lon_target + 0.5];

% 比湿範囲インデックス
lat_idx_q = find(lat_q >= lat_range(1) & lat_q <= lat_range(2));
lon_idx_q = find(lon_q >= lon_range(1) & lon_q <= lon_range(2));

% CAPE平均値計算
cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, :), 1), 2));

% 比湿平均値計算
q_selected = q_data(lon_idx_q, lat_idx_q, 2, :); % 850 hPaの比湿
q_avg = squeeze(mean(mean(q_selected, 1), 2));

% DLS計算
u_500 = u_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
v_500 = v_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
u_1000 = u_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);
v_1000 = v_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);

dls = sqrt((u_500 - u_1000).^2 + (v_500 - v_1000).^2); % 深層シアー
dls_avg = squeeze(mean(mean(dls, 1), 2));

% 降水量計算
precip_volume_avg = [];
precip_times = datetime.empty;

for t = 0:num_time_steps-1
    xrain_time = time_start + t * time_step;
    xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN山形\60mn\07', ...
        sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
    
    if ~exist(xrain_file, 'file')
        fprintf('File %s does not exist. Skipping...\n', xrain_file);
        continue;
    end
    
    data = readmatrix(xrain_file);
    valid_data = data(data >= 0);
    
    if isempty(valid_data)
        fprintf('No valid data in file %s. Skipping...\n', xrain_file);
        continue;
    end
    
    valid_data_m = valid_data / 1000;
    valid_volume = valid_data_m * (250 * 250); % 体積[m³]
    
    precip_volume_avg(end+1) = mean(valid_volume);
    precip_times(end+1) = xrain_time;
end









% cape_avg, q_avg, dls_avg, precip_volume_avg, precip_timesが存在するものとする


% 降水量データの時間範囲を制限
start_time_limit = datetime(2024, 7, 23, 0, 0, 0); % 開始時刻 (例: 2024/07/24 00:00)
end_time_limit = datetime(2024, 7, 27, 0, 0, 0);   % 終了時刻 (例: 2024/07/26 00:00)

% 制限された時間範囲内のデータのみ選択
valid_indices = (precip_times >= start_time_limit) & (precip_times <= end_time_limit);
precip_times_limited = precip_times(valid_indices);
precip_volume_avg_limited = precip_volume_avg(valid_indices);

% 時間軸の共通部分を計算
[common_times, idx_precip, idx_other] = intersect(precip_times_limited, time_axis);

% データの共通部分を抽出
precip_common = precip_volume_avg_limited(idx_precip);
cape_common = cape_avg(idx_other);
q_common = q_avg(idx_other);
dls_common = dls_avg(idx_other);

% 相互相関の計算
% CAPEと降水量
[corr_cape, lags_cape] = xcorr(precip_common - mean(precip_common), ...
                               cape_common - mean(cape_common), 'coeff');

% 比湿と降水量
[corr_q, lags_q] = xcorr(precip_common - mean(precip_common), ...
                         q_common - mean(q_common), 'coeff');

% DLSと降水量
[corr_dls, lags_dls] = xcorr(precip_common - mean(precip_common), ...
                             dls_common - mean(dls_common), 'coeff');

% 相互相関プロット
figure;

% CAPEと降水量
subplot(3, 1, 1);
plot(lags_cape, corr_cape, '-b', 'LineWidth', 1.5);
xlabel('タイムラグ (時間ステップ)');
ylabel('相関係数');
title('降水量とCAPEの相互相関');
grid on;

% 比湿と降水量
subplot(3, 1, 2);
plot(lags_q, corr_q, '-g', 'LineWidth', 1.5);
xlabel('タイムラグ (時間ステップ)');
ylabel('相関係数');
title('降水量と比湿の相互相関');
grid on;

% DLSと降水量
subplot(3, 1, 3);
plot(lags_dls, corr_dls, '-m', 'LineWidth', 1.5);
xlabel('タイムラグ (時間ステップ)');
ylabel('相関係数');
title('降水量とDLSの相互相関');
grid on;

% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\plot\2024山形線状降水帯', '相互相関プロット.png'));
