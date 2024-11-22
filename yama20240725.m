%1日分のデータ読み取り＆プロットのプログラム



% addpath 'C:\Users\murqk\Desktop\EN\'

info = ncinfo('20240725.nc');

% NetCDFファイルからデータを読み込む
data = ncread('20240725.nc', 'cape');

lat = ncread('20240725.nc', 'latitude'); % 緯度データを読み込む
lon = ncread('20240725.nc', 'longitude'); % 経度データを読み込む

% 特定の時間ステップ（例えば1番目）のデータを取り出す
time_index = 8; % プロットしたい時間ステップ（1～8）を指定
data_slice = data(:,:,time_index);

%{
% プロットの作成
figure;
S=shaperead('JPN_adm1.shp');
mapshow(S);
grid on
hold on

pcolor(lon, lat, data_slice');
shading interp; % 補間をかけて滑らかに表示
colorbar; % カラーバーを表示
xlabel('経度');
ylabel('緯度');
title(['時間ステップ ' num2str(time_index) ' のデータ']);


hold off



%}


%{
% シェープファイルのパスを適切に設定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp'); % シェープファイルのパスを確認

% プロットの作成
figure;


% pcolorプロット
pcolor(lon, lat, data_slice');
shading interp; % 補間をかけて滑らかに表示
colorbar; % カラーバーを表示
xlabel('経度');
ylabel('緯度');
title(['時間ステップ ' num2str(time_index) ' のデータ']);

mapshow(S, 'FaceColor', 'none'); % 日本地図を表示（輪郭のみ）
hold on;

% 地図上にグリッドを追加
grid on;

hold off;

%}



% シェープファイルのパスを適切に設定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp'); % シェープファイルのパスを確認

% プロットする緯度と経度の範囲を指定（例: 北緯30度〜45度、東経130度〜145度）
lat_range = [35 40];
lon_range = [138 145];

% 指定した範囲のインデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 指定した範囲のデータを取り出す
lat_sub = lat(lat_idx);
lon_sub = lon(lon_idx);
data_sub = data_slice(lon_idx, lat_idx);

% プロットの作成
figure;

% pcolorプロット
pcolor(lon_sub, lat_sub, data_sub');
shading interp; % 補間をかけて滑らかに表示
colorbar; % カラーバーを表示
xlabel('経度');
ylabel('緯度');
title(['時間ステップ ' num2str(time_index) ' のデータ (指定範囲)']);

% 日本地図の枠を表示
hold on;
mapshow(S, 'FaceColor', 'none'); % 日本地図を表示（輪郭のみ）
grid on;
hold off;


