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
lon_target = 140.5; % 中心経度
lat_range = [lat_target - 2.0, lat_target + 2.0];
lon_range = [lon_target - 1.5, lon_target + 1.5];

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

% 緯度経度の範囲
target_lat_range = [37, 41]; % 中心緯度 ± 0.5
target_lon_range = [139, 142]; % 中心経度 ± 0.5

for t = 0:num_time_steps-1
    xrain_time = time_start + t * time_step;
    xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN山形\60mn\07', ...
        sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
    
    if ~exist(xrain_file, 'file')
        fprintf('File %s does not exist. Skipping...\n', xrain_file);
        continue;
    end
    
    % CSVからデータ読み込み
    data = readmatrix(xrain_file);
    
    % 緯度経度の生成
    latitudes = linspace(41, 37, 480);  % 北から南へ
    longitudes = linspace(139, 142, 320); % 西から東へ
    
    % 対象範囲内のデータのみを抽出
    lat_indices = find(latitudes >= target_lat_range(1) & latitudes <= target_lat_range(2));
    lon_indices = find(longitudes >= target_lon_range(1) & longitudes <= target_lon_range(2));
    
    % 範囲内のデータ抽出
    valid_data = data(lat_indices, lon_indices);
    valid_data = valid_data(valid_data >= 0); % 0以上のデータのみ扱う
    
    if isempty(valid_data)
        fprintf('No valid data in file %s. Skipping...\n', xrain_file);
        continue;
    end
    
    % 体積計算
    valid_volume = valid_data / 1000 * (250 * 250); % 体積[m³]
    
    % 平均降水量計算
    precip_volume_avg(end+1) = mean(valid_volume);
    precip_times(end+1) = xrain_time;
end













% % %  ファイルの内容すべてについて平均をとる方
% % 降水量計算
% precip_volume_avg = [];
% precip_times = datetime.empty;
% 
% for t = 0:num_time_steps-1
%     xrain_time = time_start + t * time_step;
%     xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN山形\60mn\07', ...
%         sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
% 
%     if ~exist(xrain_file, 'file')
%         fprintf('File %s does not exist. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     data = readmatrix(xrain_file);
%     valid_data = data(data >= 0);
% 
%     if isempty(valid_data)
%         fprintf('No valid data in file %s. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     valid_data_m = valid_data / 1000;
%     valid_volume = valid_data_m * (250 * 250); % 体積[m³]
% 
%     precip_volume_avg(end+1) = mean(valid_volume);
%     precip_times(end+1) = xrain_time;
% end


%% JTLNデータ読み取り
%% パラメータ設定
% データディレクトリのベースパス
base_dir = 'C:\Users\murqk\Desktop\JTLN0720~0729\2024\07\';
addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス

% % 時間設定
% start_time = datetime(2024, 7, 20, 0, 0, 0); % データ開始時刻
% end_time = datetime(2024, 7, 29, 23, 50, 00); % データ終了時刻
% time_step = hours(1); % 時間ステップ (1時間)
% 
% % 緯度経度の範囲
% lat_range = [38.5, 39.5]; % 緯度範囲
% lon_range = [139.5, 140.5]; % 経度範囲
% 
% % 時間軸作成
% time_axis = start_time:time_step:end_time;
% num_time_steps = length(time_axis) - 1; % 時間区間数

% 結果保存用変数
lightning_counts = zeros(num_time_steps, 1); % 時間ごとの雷の個数

%% データ処理
for t = 1:num_time_steps
    % 現在の時間
    curr_time = time_axis(t);

    % 対応するディレクトリを構築
    curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));

    % JSONファイル名を構築
    file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
    json_file = fullfile(curr_date_dir, file_pattern);

    % JSONファイルが存在しない場合はスキップ
    if ~isfile(json_file)
        fprintf('File %s does not exist. Skipping...\n', json_file);
        continue;
    end

    % JSONファイルの読み込み
    [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);

    % 緯度経度フィルタ
    lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
    lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);

    % 現在の時間枠内のデータをカウント
    valid_idx = lat_idx & lon_idx & (time >= curr_time & time < (curr_time + time_step));
    lightning_counts(t) = sum(valid_idx);
end


% サブプロット作成
figure;

% サブプロット1: 降水量とCAPE
subplot(4, 1, 1);
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
yyaxis right;
plot(precip_times, precip_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');
xlabel('時間 (JST)');
title('CAPEおよび降水量の時系列');
legend('CAPE',  '降水量（体積 PV）');
grid on;

% サブプロット2: 比湿
subplot(4, 1, 2);
plot(time_axis, q_avg, '-g', 'LineWidth', 1.5);
ylabel('比湿 (kg/kg)');
xlabel('時間 (JST)');
title('比湿の時系列');
legend('比湿 (q)');
grid on;

% サブプロット3: DLS
subplot(4, 1, 3);
plot(time_axis, dls_avg, '-m', 'LineWidth', 1.5);
ylabel('DLS (m/s)');
xlabel('時間 (JST)');
title('DLSの時系列');
legend('DLS');
grid on;

% サブプロット4: 雷の個数
subplot(4, 1, 4);
plot(time_axis, lightning_counts, 'LineWidth', 1.5);
ylabel('雷の個数');
xlabel('時間 (JST)');
title('雷の時系列');
legend('雷の個数');
grid on;

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\\plot\2024山形線状降水帯', '5つの指標サブプロット時系列(範囲東北).png'));
