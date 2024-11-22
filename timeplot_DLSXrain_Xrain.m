% ファイルから風速データの読み込み
u_data = ncread('202407210729UTmodel_cloud.nc', 'u'); % 東西風
v_data = ncread('202407210729UTmodel_cloud.nc', 'v'); % 南北風
lat = ncread('202407210729UTmodel_cloud.nc', 'latitude');
lon = ncread('202407210729UTmodel_cloud.nc', 'longitude');

% 圧力レベルのインデックス
level_500hpa_idx = 1; % 500 hPa
level_1000hpa_idx = 3; % 1000 hPa

% 観測範囲の緯度・経度を指定
lat_target = 39; % 中心緯度
lon_target = 140; % 中心経度
lat_range = [lat_target - 0.5, lat_target + 0.5];
lon_range = [lon_target - 0.5, lon_target + 0.5];

% 範囲インデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 範囲内の風成分データを取得
u_500hpa = squeeze(mean(mean(u_data(lon_idx, lat_idx, level_500hpa_idx, :), 1), 2));
v_500hpa = squeeze(mean(mean(v_data(lon_idx, lat_idx, level_500hpa_idx, :), 1), 2));
u_1000hpa = squeeze(mean(mean(u_data(lon_idx, lat_idx, level_1000hpa_idx, :), 1), 2));
v_1000hpa = squeeze(mean(mean(v_data(lon_idx, lat_idx, level_1000hpa_idx, :), 1), 2));

% DLSの計算
DLS = sqrt((u_500hpa - u_1000hpa).^2 + (v_500hpa - v_1000hpa).^2);

% 時間軸の設定（JSTに変換：UTC + 9時間）
time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9);
time_step = hours(1); % 1時間ごと
num_time_steps = length(DLS);
time_axis = time_start + (0:num_time_steps-1) * time_step;

% 降水量（体積）の計算
precip_volume_avg = []; % m³単位の降水量平均値
precip_times = datetime.empty; % 有効なファイルの時間を記録

for t = 0:num_time_steps-1
    xrain_time = time_start + t * time_step;
    xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN\10mn\07', sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
    
    if ~exist(xrain_file, 'file')
        fprintf('File %s does not exist. Skipping...\n', xrain_file);
        continue;
    end
    
    % CSVファイルの読み込み
    data = readmatrix(xrain_file);
    
    % 欠損値のフィルタリング（例: -9999 を無視する）
    valid_data = data(data >= 0); % 0以上の値のみを抽出
    
    if isempty(valid_data)
        fprintf('No valid data in file %s. Skipping...\n', xrain_file);
        continue;
    end
    
    % mm -> m に変換し、250m×250mを掛けて体積[m³]を計算
    valid_data_m = valid_data / 1000; % mm -> m
    valid_volume = valid_data_m * (250 * 250); % 体積[m³]に変換
    
    % 有効なデータの体積平均値を計算
    precip_volume_avg(end+1) = mean(valid_volume); % 平均体積[m³]
    precip_times(end+1) = xrain_time; % 有効な時刻を記録
end

% DLSと降水量の時系列プロット
figure;
yyaxis left;
plot(time_axis, DLS, '-b', 'LineWidth', 1.5);
ylabel('DLS (m/s)');
xlabel('時間 (JST)');
title('時間ごとのDLSと降水量（体積）');

% 降水量（体積）のプロット
yyaxis right;
plot(precip_times, precip_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');

legend('DLS', '降水量（体積）');
grid on;

% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯', 'DLS_降水量時系列プロット.png'));
