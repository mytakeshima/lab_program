% 数日間にわたるデータの読み取りとプロット方法

info = ncinfo('202407210729UTmodel_cloud.nc');


% NetCDFファイルからデータを読み込む
data = ncread('202407210729UTmodel_cloud.nc', 'r'); % 相対湿度
lat = ncread('202407210729UTmodel_cloud.nc', 'latitude'); % 緯度
lon = ncread('202407210729UTmodel_cloud.nc', 'longitude'); % 経度

%それぞれの変数の略称
% cc: Fraction of cloud cover（雲量）
% r: Relative humidity（相対湿度）
% q: Specific humidity（比湿）
% t: Temperature（気温）
% u: U-component of wind（東西風成分）
% v: V-component of wind（南北風成分）
% w: Vertical velocity（鉛直速度）

% シェープファイルのパスを適切に設定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp');

% プロット範囲の設定
lat_range = [37 41];
lon_range = [139 142];
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));
lat_sub = lat(lat_idx);
lon_sub = lon(lon_idx);

% 指定圧力レベル（例: 550 hPaに対応するインデックス）
level_idx = 2; % 例として3つのレベルのうちの2番目を指定

% 開始日時
start_time = datetime(2024, 7, 21, 0, 0, 0);

% 各時間ステップに対するプロットのループ
for time_index = 16:231
    current_time = start_time + hours(time_index - 16);
    data_slice = data(:,:,level_idx,time_index);
    data_sub = data_slice(lon_idx, lat_idx);

    % プロットの作成
    figure('Visible', 'off');
    pcolor(lon_sub, lat_sub, data_sub');
    shading interp;
    colorbarHandle = colorbar;
    xlabel('経度');
    ylabel('緯度');
    title(['日時: ' datestr(current_time, 'yyyy/mm/dd HH:MM (LT)')]);
    ylabel(colorbarHandle, '相対湿度 (%)');

    % 日本地図の枠を表示
    hold on;
    mapshow(S, 'FaceColor', 'none');
    grid on;
    hold off;

    % プロットの保存
    saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\07210729相対湿度\', ['plot_' num2str(time_index-15) '.png']));

    % 図を閉じる
    close(gcf);
end
