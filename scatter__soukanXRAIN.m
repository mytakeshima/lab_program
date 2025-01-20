% 
% % 必要なデータの読み込み
% cloud_file = '202407210729UTmodel_cloud.nc';
% cape_file = '202407210729UTmodel_cape.nc';
% rain_file = '202407210729UTmodel_rain.nc';
% 
% % 比湿データ
% q_data = ncread(cloud_file, 'q'); % 比湿データ
% lat_q = ncread(cloud_file, 'latitude');
% lon_q = ncread(cloud_file, 'longitude');
% 
% % CAPEデータ
% cape_data = ncread(cape_file, 'cape');
% 
% % 風速データ（DLS計算用）
% u_data = ncread(cloud_file, 'u'); % 東西風
% v_data = ncread(cloud_file, 'v'); % 南北風
% 
% % 圧力レベル（DLS用）
% level_500hpa_idx = 1; % 500 hPa
% level_1000hpa_idx = 3; % 1000 hPa
% 
% % 時間軸設定
% time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9); % JST
% time_step = hours(1);
% num_time_steps = size(q_data, 4);
% time_axis = time_start + (0:num_time_steps-1) * time_step;
% 
% % 緯度・経度の範囲設定
% lat_target = 39; % 中心緯度
% lon_target = 140; % 中心経度
% lat_range = [lat_target - 0.5, lat_target + 0.5];
% lon_range = [lon_target - 0.5, lon_target + 0.5];
% 
% % 比湿範囲インデックス
% lat_idx_q = find(lat_q >= lat_range(1) & lat_q <= lat_range(2));
% lon_idx_q = find(lon_q >= lon_range(1) & lon_q <= lon_range(2));
% 
% % CAPE平均値計算
% cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, :), 1), 2));
% 
% % 比湿平均値計算
% q_selected = q_data(lon_idx_q, lat_idx_q, 2, :); % 850 hPaの比湿
% q_avg = squeeze(mean(mean(q_selected, 1), 2));
% 
% % DLS計算
% u_500 = u_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
% v_500 = v_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
% u_1000 = u_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);
% v_1000 = v_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);
% 
% dls = sqrt((u_500 - u_1000).^2 + (v_500 - v_1000).^2); % 深層シアー
% dls_avg = squeeze(mean(mean(dls, 1), 2));
% 
% 
% 
% % 降水量計算
% precip_volume_avg = [];
% precip_times = datetime.empty;
% 
% % 緯度経度の範囲
% target_lat_range = [37, 41]; % 中心緯度 ± 0.5
% target_lon_range = [139, 142]; % 中心経度 ± 0.5
% 
% for t = 0:num_time_steps-1
%     xrain_time = time_start + t * time_step;
%     xrain_file = fullfile('E:\XRAIN(東北)\202407200900-202407290900-60-THK-139.0000-41.0000-142.0000-37.0000\', ...
%         sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
% 
%     if ~exist(xrain_file, 'file')
%         fprintf('File %s does not exist. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     % CSVからデータ読み込み
%     data = readmatrix(xrain_file);
% 
%     % 緯度経度の生成
%     latitudes = linspace(41, 37, 1920);  % 北から南へ
%     longitudes = linspace(139, 142, 960); % 西から東へ
% 
%     % 対象範囲内のデータのみを抽出
%     lat_indices = find(latitudes >= lat_range(1) & latitudes <= lat_range(2));
%     lon_indices = find(longitudes >= lon_range(1) & longitudes <= lon_range(2));
% 
%     % 範囲内のデータ抽出
%     valid_data = data(lat_indices, lon_indices);
%     valid_data = valid_data(valid_data >= 0); % 0以上のデータのみ扱う
% 
%     if isempty(valid_data)
%         fprintf('No valid data in file %s. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     % 体積計算
%     valid_volume = valid_data / 1000 * (250 * 250); % 体積[m³]
% 
%     % 平均降水量計算
%     precip_volume_avg(end+1) = mean(valid_volume);
%     precip_times(end+1) = xrain_time;
% end
% 
% 
% 
% 
% 
% 
% % % 降水量計算
% % precip_volume_avg = [];
% % precip_times = datetime.empty;
% % 
% % for t = 0:num_time_steps-1
% %     xrain_time = time_start + t * time_step;
% %     xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN山形\60mn\07', ...
% %         sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
% % 
% %     if ~exist(xrain_file, 'file')
% %         fprintf('File %s does not exist. Skipping...\n', xrain_file);
% %         continue;
% %     end
% % 
% %     data = readmatrix(xrain_file);
% %     valid_data = data(data >= 0);
% % 
% %     if isempty(valid_data)
% %         fprintf('No valid data in file %s. Skipping...\n', xrain_file);
% %         continue;
% %     end
% % 
% %     valid_data_m = valid_data / 1000;
% %     valid_volume = valid_data_m * (250 * 250); % 体積[m³]
% % 
% %     precip_volume_avg(end+1) = mean(valid_volume);
% %     precip_times(end+1) = xrain_time;
% % end
% 
% 
% %% JTLNデータ読み取り
% %% パラメータ設定
% % データディレクトリのベースパス
% base_dir = 'E:\JTLN0720~0729\2024\07';
% addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス
% 
% 
% % 結果保存用変数
% lightning_counts = zeros(num_time_steps, 1); % 時間ごとの雷の個数
% 
% %% データ処理
% for t = 1:num_time_steps
%     % 現在の時間
%     curr_time = time_axis(t);
% 
%     % 対応するディレクトリを構築
%     curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));
% 
%     % JSONファイル名を構築
%     file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
%     json_file = fullfile(curr_date_dir, file_pattern);
% 
%     % JSONファイルが存在しない場合はスキップ
%     if ~isfile(json_file)
%         fprintf('File %s does not exist. Skipping...\n', json_file);
%         continue;
%     end
% 
%     % JSONファイルの読み込み
%     [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
% 
%     % 緯度経度フィルタ
%     lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
%     lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);
% 
%     % 現在の時間枠内のデータをカウント
%     valid_idx = lat_idx & lon_idx & (time >= curr_time & time < (curr_time + time_step));
%     lightning_counts(t) = sum(valid_idx);
% end
% 
% 
% 
% 
% 
% 
% 
% % cape_avg, q_avg, dls_avg, precip_volume_avg, precip_timesが存在するものとする
% 
% % 降水量の時間軸と他データの時間軸を揃える
% [common_times, idx_precip, idx_other] = intersect(precip_times, time_axis);
% 
% % データの共通部分を抽出
% precip_common = precip_volume_avg(idx_precip);
% cape_common = cape_avg(idx_other);
% q_common = q_avg(idx_other);
% dls_common = dls_avg(idx_other);
% 
% lightning_common = lightning_counts(idx_other);
% 
% % 相互相関の計算
% % CAPEと降水量
% [corr_cape, lags_cape] = xcorr(precip_common - mean(precip_common), ...
%                                cape_common - mean(cape_common), 'coeff');
% 
% % 比湿と降水量
% [corr_q, lags_q] = xcorr(precip_common - mean(precip_common), ...
%                          q_common - mean(q_common), 'coeff');
% 
% % DLSと降水量
% [corr_dls, lags_dls] = xcorr(precip_common - mean(precip_common), ...
%                              dls_common - mean(dls_common), 'coeff');
% 
% %雷と降水量
% [corr_lightning, lags_lightning] = xcorr(precip_common - mean(precip_common), ...
%                              lightning_common - mean(lightning_common), 'coeff');
% 
% 
% 
% % 相関係数が最も高いタイムラグのインデックスを求める
% [~, max_idx_cape] = max(abs(corr_cape));
% [~, max_idx_q] = max(abs(corr_q));
% [~, max_idx_dls] = max(abs(corr_dls));
% [~, max_idx_lightning] = max(abs(corr_lightning));
% 
% % 最も高い相関のタイムラグを取得
% lag_cape = lags_cape(max_idx_cape);
% lag_q = lags_q(max_idx_q);
% lag_dls = lags_dls(max_idx_dls);
% lag_lightning = lags_lightning(max_idx_lightning);
% 
% % データをタイムラグに応じてシフト
% precip_shifted_cape = circshift(precip_common, -lag_cape);
% precip_shifted_q = circshift(precip_common, -lag_q);
% precip_shifted_dls = circshift(precip_common, -lag_dls);
% precip_shifted_lightning = circshift(precip_common, -lag_lightning);
% 
% 
% % CAPEと降水量の上位10点
% [sorted_values_cape, sorted_indices_cape] = sort(abs(cape_common - mean(cape_common)) .* abs(precip_shifted_cape - mean(precip_shifted_cape)), 'descend');
% top_10_indices_cape = sorted_indices_cape(1:10);
% top_10_times_cape = common_times(top_10_indices_cape);
% 
% 
% 
% % DLSと降水量の上位10点
% [sorted_values_dls, sorted_indices_dls] = sort(abs(dls_common - mean(dls_common)) .* abs(precip_shifted_dls - mean(precip_shifted_dls)), 'descend');
% top_10_indices_dls = sorted_indices_dls(1:10);
% top_10_times_dls = common_times(top_10_indices_dls);
% 
% % 比湿と降水量の上位10点
% [sorted_values_q, sorted_indices_q] = sort(abs(q_common - mean(q_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
% top_10_indices_q = sorted_indices_q(1:10);
% top_10_times_q = common_times(top_10_indices_q);
% 
% % 雷と降水量の上位10点
% [sorted_values_lightning, sorted_indices_lightning] = sort(abs(lightning_common - mean(lightning_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
% top_10_indices_lightning = sorted_indices_lightning(1:10);
% top_10_times_lightning = common_times(top_10_indices_lightning);
% 
% 
% 
% % 結果の表示
% fprintf('CAPEと降水量の相関に寄与する上位10点の時刻:\n');
% for i = 1:10
%     fprintf('%d: %s\n', i, datestr(top_10_times_cape(i)));
% end
% 
% 
% fprintf('\nDLSと降水量の相関に寄与する上位10点の時刻:\n');
% for i = 1:10
%     fprintf('%d: %s\n', i, datestr(top_10_times_dls(i)));
% end
% 
% fprintf('\n比湿と降水量の相関に寄与する上位10点の時刻:\n');
% for i = 1:10
%     fprintf('%d: %s\n', i, datestr(top_10_times_q(i)));
% end
% 
% fprintf('\n雷と降水量の相関に寄与する上位10点の時刻:\n');
% for i = 1:10
%     fprintf('%d: %s\n', i, datestr(top_10_times_lightning(i)));
% end
% 
% 
% 
% 
% % 散布図プロット
% figure;
% 
% % CAPEと降水量
% subplot(4, 1, 1);
% scatter(cape_common, precip_shifted_cape, 'b', 'filled');
% xlabel('CAPE');
% ylabel('降水量');
% title(sprintf('降水量とCAPEの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
%     -lag_cape, corr_cape(max_idx_cape)));
% grid on;
% 
% 
% % DLSと降水量
% subplot(4, 1, 2);
% scatter(dls_common, precip_shifted_dls, 'm', 'filled');
% xlabel('DLS');
% ylabel('降水量');
% title(sprintf('降水量とDLSの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
%     -lag_dls, corr_dls(max_idx_dls)));
% grid on;
% 
% 
% % 比湿と降水量
% subplot(4, 1, 3);
% scatter(q_common, precip_shifted_q, 'g', 'filled');
% xlabel('比湿');
% ylabel('降水量');
% title(sprintf('降水量と比湿の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
%     -lag_q, corr_q(max_idx_q)));
% grid on;
% 
% % 雷と降水量
% subplot(4, 1, 4);
% scatter(lightning_common, precip_shifted_lightning, 'r', 'filled');
% xlabel('雷');
% ylabel('降水量');
% title(sprintf('降水量と雷の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
%     -lag_lightning, corr_lightning(max_idx_lightning)));
% grid on;
% 
% 
% % プロットの保存
% saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\plot\2024山形線状降水帯', '散布図プロット(範囲山形).png'));


% 必要なデータの読み込み (既存プログラムに基づく前処理が済んでいることを前提)

% 必要なデータの読み込み
cloud_file = '202407210729UTmodel_cloud.nc';
cape_file = '202407210729UTmodel_cape.nc';
% rain_file = '202407210729UTmodel_rain.nc';

% 比湿データ
q_data = ncread(cloud_file, 'q'); % 比湿データ
lat_q = ncread(cloud_file, 'latitude');
lon_q = ncread(cloud_file, 'longitude');

% % 降水量データ
% rain_data =ncread(rain_file, 'tp');

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
lat_range = [38.5, 39.5];
lon_range = [139.5, 140.5];

% 比湿範囲インデックス
lat_idx_q = find(lat_q >= lat_range(1) & lat_q <= lat_range(2));
lon_idx_q = find(lon_q >= lon_range(1) & lon_q <= lon_range(2));

% CAPE平均値計算
cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, :), 1), 2));

% % 領域の面積 (m²) の計算
% vert_length = 27.75 * 1000;  % 縦方向 (m)
% horiz_length = 21.88 * 1000; % 横方向 (m)
% area_ERA5 = vert_length * horiz_length;  % 面積 (m²)
% 
% % 降水量データを体積に変換
% rain_volume = rain_data(lon_idx_q, lat_idx_q, :) * area_ERA5; %m^3
% 
% % 降水量平均値計算
% rain_volume_avg = squeeze(mean(mean(rain_volume, 1), 2)); % グリッドごとの平均降水量



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

% % 緯度経度の範囲
% target_lat_range = [37, 41]; % 中心緯度 ± 0.5
% target_lon_range = [139, 142]; % 中心経度 ± 0.5

for t = 0:num_time_steps-1
    xrain_time = time_start + t * time_step;
    xrain_file = fullfile('E:\XRAIN累積降水量ver2(東北)\7\', ...
        sprintf('202407%02d-%02d.csv', day(xrain_time), hour(xrain_time)));

    if ~exist(xrain_file, 'file')
        fprintf('File %s does not exist. Skipping...\n', xrain_file);
        continue;
    end

    % CSVからデータ読み込み
    data = readmatrix(xrain_file);
    fprintf('File %s loaded successfully.\n', xrain_file);  % 読み込み成功メッセージ  
    % 緯度経度の生成
    latitudes = linspace(41, 37, 1920);  % 北から南へ
    longitudes = linspace(139, 142, 960); % 西から東へ

    % 対象範囲内のデータのみを抽出
    lat_indices = find(latitudes >= lat_range(1) & latitudes <= lat_range(2));
    lon_indices = find(longitudes >= lon_range(1) & longitudes <= lon_range(2));

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








%% JTLNデータ読み取り
%% パラメータ設定
% データディレクトリのベースパス
base_dir = 'E:\JTLN0720~0729\2024\07';
addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス


% 結果保存用変数
lightning_counts = zeros(num_time_steps, 1); % 時間ごとの雷の個数


%% データ処理
for t = 1:num_time_steps
    % 現在の時間
    curr_time = time_axis(t) - hours(9);

    % 累積する雷の数の初期化
    cumulative_lightning_count = 0;

    % 10分間隔のファイルを処理
    for minute = 0:10:50
        % 現在の時間から10分間隔の時間を設定
        specific_time = curr_time + minutes(minute);

        % 対応するディレクトリを構築
        curr_date_dir = fullfile(base_dir, datestr(specific_time, 'dd'));

        % JSONファイル名を構築
        file_pattern = sprintf('FLASHES_%s.json', datestr(specific_time, 'yyyy-mm-ddTHH-MM'));
        json_file = fullfile(curr_date_dir, file_pattern);

        % JSONファイルが存在しない場合はスキップ
        if ~isfile(json_file)
            fprintf('File %s does not exist. Skipping...\n', json_file);
            continue;
        end

        % JSONファイルの読み込み
        [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
         fprintf('JSON file %s loaded successfully.\n', json_file);  % 読み込み成功メッセージ


        % 緯度経度フィルタ
        lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
        lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);

        % 現在の時間枠内のデータをカウント
        % valid_idx = lat_idx & lon_idx & (time >= specific_time & time < (specific_time + minutes(10)));
        valid_idx = lat_idx & lon_idx
        cumulative_lightning_count = cumulative_lightning_count + sum(valid_idx);
    end

    % 時間ステップごとの累積雷の数を記録
    lightning_counts(t) = cumulative_lightning_count;
end


% %% データ処理
% for t = 1:num_time_steps
%     % 現在の時間
%     curr_time = time_axis(t);
% 
%     % 対応するディレクトリを構築
%     curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));
% 
%     % JSONファイル名を構築
%     file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
%     json_file = fullfile(curr_date_dir, file_pattern);
% 
%     % JSONファイルが存在しない場合はスキップ
%     if ~isfile(json_file)
%         fprintf('File %s does not exist. Skipping...\n', json_file);
%         continue;
%     end
% 
%     % JSONファイルの読み込み
%     [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
% 
%     % 緯度経度フィルタ
%     lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
%     lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);
% 
%     % 現在の時間枠内のデータをカウント
%     valid_idx = lat_idx & lon_idx & (time >= curr_time & time < (curr_time + time_step));
%     lightning_counts(t) = sum(valid_idx);
% end






% 時間軸の共通部分を抽出
[common_times, idx_precip, idx_other] = intersect(time_axis, time_axis, 'stable');

% データの共通部分を抽出
precip_common = precip_volume_avg(idx_precip);
cape_common = cape_avg(idx_other);
q_common = q_avg(idx_other);
dls_common = dls_avg(idx_other);
lightning_common = lightning_counts(idx_other);

% 相互相関の計算
[corr_cape, lags_cape] = xcorr(precip_common - mean(precip_common), ...
                               cape_common - mean(cape_common), 'coeff');
[corr_q, lags_q] = xcorr(precip_common - mean(precip_common), ...
                         q_common - mean(q_common), 'coeff');
[corr_dls, lags_dls] = xcorr(precip_common - mean(precip_common), ...
                             dls_common - mean(dls_common), 'coeff');
[corr_lightning, lags_lightning] = xcorr(precip_common - mean(precip_common), ...
                                         lightning_common - mean(lightning_common), 'coeff');


% 相関係数が最も高いタイムラグのインデックスを求める
[~, max_idx_cape] = max(abs(corr_cape));
[~, max_idx_q] = max(abs(corr_q));
[~, max_idx_dls] = max(abs(corr_dls));
[~, max_idx_lightning] = max(abs(corr_lightning));

% 最も高い相関のタイムラグを取得
lag_cape = lags_cape(max_idx_cape);
lag_q = lags_q(max_idx_q);
lag_dls = lags_dls(max_idx_dls);
lag_lightning = lags_lightning(max_idx_lightning);

% データをタイムラグに応じてシフト
precip_shifted_cape = circshift(precip_common, -lag_cape);
precip_shifted_q = circshift(precip_common, -lag_q);
precip_shifted_dls = circshift(precip_common, -lag_dls);
precip_shifted_lightning = circshift(precip_common, -lag_lightning);


% CAPEと降水量の上位10点
[sorted_values_cape, sorted_indices_cape] = sort(abs(cape_common - mean(cape_common)) .* abs(precip_shifted_cape - mean(precip_shifted_cape)), 'descend');
top_10_indices_cape = sorted_indices_cape(1:10);
top_10_times_cape = common_times(top_10_indices_cape);



% DLSと降水量の上位10点
[sorted_values_dls, sorted_indices_dls] = sort(abs(dls_common - mean(dls_common)) .* abs(precip_shifted_dls - mean(precip_shifted_dls)), 'descend');
top_10_indices_dls = sorted_indices_dls(1:10);
top_10_times_dls = common_times(top_10_indices_dls);

% 比湿と降水量の上位10点
[sorted_values_q, sorted_indices_q] = sort(abs(q_common - mean(q_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
top_10_indices_q = sorted_indices_q(1:10);
top_10_times_q = common_times(top_10_indices_q);

% 雷と降水量の上位10点
[sorted_values_lightning, sorted_indices_lightning] = sort(abs(lightning_common - mean(lightning_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
top_10_indices_lightning = sorted_indices_lightning(1:10);
top_10_times_lightning = common_times(top_10_indices_lightning);



% 結果の表示
fprintf('CAPEと降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_cape(i)));
end


fprintf('\nDLSと降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_dls(i)));
end

fprintf('\n比湿と降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_q(i)));
end

fprintf('\n雷と降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_lightning(i)));
end




% 散布図プロット
figure;

% CAPEと降水量
subplot(4, 1, 1);
scatter(cape_common, precip_shifted_cape, 10, 'b', 'filled'); % サイズを20に設定
xlabel('CAPE');
ylabel('降水量');
title(sprintf('降水量とCAPEの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_cape, corr_cape(max_idx_cape)));
grid on;

% DLSと降水量
subplot(4, 1, 2);
scatter(dls_common, precip_shifted_dls, 10, 'm', 'filled'); % サイズを20に設定
xlabel('DLS');
ylabel('降水量');
title(sprintf('降水量とDLSの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_dls, corr_dls(max_idx_dls)));
grid on;

% 比湿と降水量
subplot(4, 1, 3);
scatter(q_common, precip_shifted_q, 10, 'g', 'filled'); % サイズを20に設定
xlabel('比湿');
ylabel('降水量');
title(sprintf('降水量と比湿の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_q, corr_q(max_idx_q)));
grid on;

% 雷と降水量
subplot(4, 1, 4);
scatter(lightning_common, precip_shifted_lightning, 10, 'r', 'filled'); % サイズを20に設定
xlabel('雷');
ylabel('降水量');
title(sprintf('降水量と雷の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_lightning, corr_lightning(max_idx_lightning)));
grid on;


% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\山形\XRAIN累積降水量使用', '散布図プロット(範囲山形).png'));
