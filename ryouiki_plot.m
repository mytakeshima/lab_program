% 指定範囲の赤枠表示のプログラム
% データ収集領域を示すときに使用

% 地図のファイルパス
shapefile = 'C:\Users\murqk\Desktop\EN\JPN_adm1.shp';

% 地図の読み込み
S = shaperead(shapefile);

% 地図の描画
figure;
mapshow(S, 'EdgeColor', 'black'); % 地図の境界線を黒色で描画
hold on;

% 指定した範囲（例：緯度・経度の範囲を設定）
lat_min = 36.9; % 最小緯度
lat_max = 37.5; % 最大緯度
lon_min = 136.6; % 最小経度
lon_max = 137.2; % 最大経度

% 赤い枠を描画
plot([lon_min, lon_max, lon_max, lon_min, lon_min], ...
     [lat_min, lat_min, lat_max, lat_max, lat_min], ...
     'r-', 'LineWidth', 2);

% 描画の設定
xlabel('経度');
ylabel('緯度');
title('指定範囲の赤枠表示');
hold off;
