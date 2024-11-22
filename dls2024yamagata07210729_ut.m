% DLS（Deep Layer Shear）の空間分布を計算しプロットするプログラム

% NetCDFファイルの情報取得
info = ncinfo('202407210729UTmodel_cloud.nc');

% NetCDFファイルから風速データを読み込む
u_data = ncread('202407210729UTmodel_cloud.nc', 'u'); % 東西風
v_data = ncread('202407210729UTmodel_cloud.nc', 'v'); % 南北風
lat = ncread('202407210729UTmodel_cloud.nc', 'latitude'); % 緯度データ
lon = ncread('202407210729UTmodel_cloud.nc', 'longitude'); % 経度データ

% シェープファイルのパスを指定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp'); % 日本地図シェープファイル

% プロット範囲の緯度・経度を指定
lat_range = [37 41];
lon_range = [139 142];

% 指定範囲のインデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 指定範囲の緯度・経度を抽出
lat_sub = lat(lat_idx);
lon_sub = lon(lon_idx);

% 圧力レベルのインデックス（500hPaと1000hPaを指定）
level_500hpa_idx = 1; % 500 hPa
level_1000hpa_idx = 3; % 1000 hPa

% 時間軸の設定
start_time = datetime(2024, 7, 20, 0, 0, 0); % 開始日時（UTC）
num_time_steps = size(u_data, 4); % 時間ステップ数

% 時間ごとのプロットのループ
for time_index = 1:num_time_steps
    % 現在の時間を計算（JSTに変換）
    current_time = start_time + hours(time_index - 1) + hours(9);

    % 現在の時間ステップのデータを取得
    u_500hpa = squeeze(u_data(lon_idx, lat_idx, level_500hpa_idx, time_index));
    v_500hpa = squeeze(v_data(lon_idx, lat_idx, level_500hpa_idx, time_index));
    u_1000hpa = squeeze(u_data(lon_idx, lat_idx, level_1000hpa_idx, time_index));
    v_1000hpa = squeeze(v_data(lon_idx, lat_idx, level_1000hpa_idx, time_index));

    % DLS（Deep Layer Shear）の計算
    DLS = sqrt((u_500hpa - u_1000hpa).^2 + (v_500hpa - v_1000hpa).^2);

    % プロットの作成
    figure('Visible', 'off'); % 新しい図を非表示で作成
    s = pcolor(lon_sub, lat_sub, DLS'); % pcolorプロット
    shading interp; % 補間をかけて滑らかに表示
    colorbarHandle = colorbar; % カラーバーを表示し、そのハンドルを取得
    xlabel('経度');
    ylabel('緯度');
    title(['日時: ' datestr(current_time, 'yyyy/mm/dd HH:MM (LT)')]);
    ylabel(colorbarHandle, 'DLS (m/s)'); % カラーバーのラベル設定

    % 日本地図の枠を表示
    hold on;
    mapshow(S, 'FaceColor', 'none'); % 日本地図を表示（輪郭のみ）
    grid on;
    hold off;

    % プロットの保存
    saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\07210729DLS\', ['plot_' num2str(time_index) '.png']));

    % 図を閉じる
    close(gcf);
end
