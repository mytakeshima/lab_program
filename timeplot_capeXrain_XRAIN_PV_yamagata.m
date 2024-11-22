% capeのデータに関しては、緯度と経度の範囲を取得したデータから制限していますが
% XRAINから得た降水量データの制限を行うのは難しそうなのでファイルダウンロードの時点で
% 緯度経度を制限してファイル内すべてのデータを用いることにしました。



% データの読み込み（CAPEデータはそのまま）
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape'); % CAPEデータ
lat = ncread('202407210729UTmodel_cape.nc', 'latitude');
lon = ncread('202407210729UTmodel_cape.nc', 'longitude');

% 観測したい範囲の緯度・経度を指定
lat_target = 39; % 中心緯度
lon_target = 140; % 中心経度
lat_range = [lat_target - 0.5, lat_target + 0.5];
lon_range = [lon_target - 0.5, lon_target + 0.5];

% 指定した範囲のインデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% CAPEデータの平均値を計算（時間軸で取得）
cape_avg = squeeze(mean(mean(cape_data(lon_idx, lat_idx, :), 1), 2));

% 時間軸の設定（JSTに変換：UTC + 9時間）
time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9);
time_step = hours(1); % 1時間ごと
num_time_steps = length(cape_avg);
time_axis = time_start + (0:num_time_steps-1) * time_step;


% XRAINデータの読み込みと体積計算（降水量[m³]の平均値）
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

% CAPEと降水量（体積）の時系列プロット
figure;
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
xlabel('時間 (JST)');
title('時間ごとのCAPEと降水量（体積）');

% 降水量（体積）のプロット
yyaxis right;
plot(precip_times, precip_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');

legend('CAPE', '降水量（体積）');
grid on;

% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\capeXrain体積時系列プロット_XRAIN', 'CAPEと降水量（体積）の折れ線グラフ.png'));
