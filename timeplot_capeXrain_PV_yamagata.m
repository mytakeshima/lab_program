% イベント情報（そのまま）

% データの読み込み（そのまま）
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape'); % CAPEデータ
precip_data = ncread('202407210729UTmodel_rain.nc', 'tp'); % 降水量データ
lat = ncread('202407210729UTmodel_cape.nc', 'latitude');
lon = ncread('202407210729UTmodel_cape.nc', 'longitude');

% 観測したい範囲の緯度・経度を指定（そのまま）
lat_target = 39; % 中心緯度
lon_target = 140; % 中心経度
lat_range = [lat_target - 0.5, lat_target + 0.5];
lon_range = [lon_target - 0.5, lon_target + 0.5];

% 指定した範囲のインデックスを取得（そのまま）
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 領域の面積 (m²) の計算
vert_length = 27.75 * 1000; % 縦方向 (m)
horiz_length = 21.88 * 1000; % 横方向 (m)
area = vert_length * horiz_length; % 面積 (m²)

% 降水量データを体積に変換
precip_volume = precip_data(lon_idx, lat_idx, :) * area; % m³
precip_volume_avg = squeeze(mean(mean(precip_volume, 1), 2)); % 時間ごとの平均

% CAPEデータの平均値を計算（そのまま）
cape_avg = squeeze(mean(mean(cape_data(lon_idx, lat_idx, :), 1), 2));

% 時間軸の設定（そのまま）
time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9); % JSTに変更
time_step = hours(1); % 1時間ごと
time_axis = time_start + (0:length(cape_avg)-1) * time_step;
num_steps = 216;

% CAPEと降水体積の時系列プロット
figure;
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
xlabel('時間 (JST)');
title('時間ごとのCAPEと降水体積');

yyaxis right;
plot(time_axis, precip_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水体積 (m³)');

legend('CAPE', '降水体積');
grid on;

% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\capeXrain体積時系列プロット', ['CAPEと降水体積の折れ線グラフ.png']));

for t = 1:num_steps
    current_time = time_start + (t - 1) * time_step;
    fprintf('Timestep = %d  |  %s\n', t, datestr(current_time, 'yyyy/mm/dd HH:MM'));
end