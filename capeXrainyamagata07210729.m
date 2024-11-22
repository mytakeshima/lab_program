% データの読み込み
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape'); % CAPEデータ
precip_data = ncread('202407210729UTmodel_rain.nc', 'tp'); % 降水量データ
lat = ncread('202407210729UTmodel_cape.nc', 'latitude');
lon = ncread('202407210729UTmodel_cape.nc', 'longitude');

% 解析範囲の緯度と経度
lat_range = [37 41];
lon_range = [139 142];
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% データ抽出期間の設定
full_start_time = datetime(2024, 7, 20, 0, 0, 0);
start_time = datetime(2024, 7, 23, 0, 0, 0); % 変更可能
end_time = datetime(2024, 7, 25, 0, 0, 0);   % 変更可能
time_step = 1; % 時間ステップ数（1時間あたり1インデックス）

% 開始インデックスと終了インデックスを計算
start_idx = hours(start_time - full_start_time) / time_step + 1;
end_idx = hours(end_time - full_start_time) / time_step + 1;

% 抽出範囲のデータを取得
cape_sub = cape_data(lon_idx, lat_idx, start_idx:end_idx);
precip_sub = precip_data(lon_idx, lat_idx, start_idx:end_idx);

% データを1次元ベクトルに変換
cape_vector = reshape(cape_sub, [], 1);
precip_vector = reshape(precip_sub, [], 1);

% 散布図の作成
figure;
scatter(cape_vector, precip_vector, 'filled', 'MarkerFaceAlpha', 0.5);
xlabel('CAPE (J/kg)');
ylabel('降水量 (mm)');
title('CAPEと降水量の散布図');
grid on;
