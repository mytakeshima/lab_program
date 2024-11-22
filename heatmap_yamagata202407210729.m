% データの読み込み
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape');
precip_data = ncread('202407210729UTmodel_rain.nc', 'tp');
lat = ncread('202407210729UTmodel_cape.nc', 'latitude');
lon = ncread('202407210729UTmodel_cape.nc', 'longitude');

% 緯度経度の範囲を指定
lat_range = [37 41];
lon_range = [139 142];
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% データ抽出期間の設定
full_start_time = datetime(2024, 7, 20, 0, 0, 0);
start_time = datetime(2024, 7, 25, 3, 0, 0); % 変更可能 UT 9時間ずらす
end_time = datetime(2024, 7, 25, 9, 0, 0);   % 変更可能 UT
time_step = 1;

% インデックス計算
start_idx = hours(start_time - full_start_time) / time_step + 1;
end_idx = hours(end_time - full_start_time) / time_step + 1;

% 平均データの取得
cape_sub = mean(cape_data(lon_idx, lat_idx, start_idx:end_idx), 3);
precip_sub = mean(precip_data(lon_idx, lat_idx, start_idx:end_idx), 3);

% シェープファイルの読み込み
japan_shape = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp');

% CAPEのヒートマップ作成
figure;
subplot(1, 2, 1);
imagesc(lon(lon_idx), lat(lat_idx), cape_sub');
cbar1 = colorbar;
cbar1.Label.String = 'CAPE (J/kg)';
title('CAPEのヒートマップ');
xlabel('経度');
ylabel('緯度');
axis xy;
hold on;
% 日本地図のプロット
for k = 1:length(japan_shape)
    plot(japan_shape(k).X, japan_shape(k).Y, 'k', 'LineWidth', 1.5);
end
hold off;

% 降水量のヒートマップ作成
subplot(1, 2, 2);
imagesc(lon(lon_idx), lat(lat_idx), precip_sub');
cbar2 = colorbar;
cbar2.Label.String = '降水量 (mm)';
title('降水量のヒートマップ');
xlabel('経度');
ylabel('緯度');
axis xy;
hold on;
% 日本地図のプロット
for k = 1:length(japan_shape)
    plot(japan_shape(k).X, japan_shape(k).Y, 'k', 'LineWidth', 1.5);
end
hold off;


% プロットの保存や表示に関する処理
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\07210729cape&rainヒートマップ\', ['cape&rainヒートマップ.png']));



