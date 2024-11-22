% 数日間にわたるデータの読み取りとプロット方法

info = ncinfo('202407210729yama.nc');

% NetCDFファイルからデータを読み込む
data = ncread('202407210729yama.nc', 'cape');

lat = ncread('202407210729yama.nc', 'latitude'); % 緯度データを読み込む
lon = ncread('202407210729yama.nc', 'longitude'); % 経度データを読み込む

% シェープファイルのパスを適切に設定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp'); % シェープファイルのパスを確認

% プロットする緯度と経度の範囲を指定（例: 北緯30度〜45度、東経130度〜145度）
lat_range = [37 41];
lon_range = [139 142];

% 指定した範囲のインデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 指定した範囲のデータを取り出す
lat_sub = lat(lat_idx);
lon_sub = lon(lon_idx);

% 開始日時の設定
start_time = datetime(2024, 7, 21, 0, 0, 0); % 2024/7/21 00:00

% 各時間ステップに対するプロットのループ
for time_index = 1:216
    % 現在の時間を計算
    current_time = start_time + hours(time_index - 1);

    % 現在の時間ステップのデータを取り出す
    data_slice = data(:,:,time_index);
    data_sub = data_slice(lon_idx, lat_idx);

    % プロットの作成
    figure('Visible', 'off'); % 新しい図を非表示で作成

    % pcolorプロット
    pcolor(lon_sub, lat_sub, data_sub');
    shading interp; % 補間をかけて滑らかに表示
    colorbarHandle = colorbar; % カラーバーを表示し、そのハンドルを取得
    xlabel('経度');
    ylabel('緯度');
    title(['日時: ' datestr(current_time, 'yyyy/mm/dd HH:MM (LT)')]);


    % カラーバーにラベルを追加
ylabel(colorbarHandle, 'CAPE J/kg'); % カラーバーのラベルを設定

    % 日本地図の枠を表示
    hold on;
    mapshow(S, 'FaceColor', 'none'); % 日本地図を表示（輪郭のみ）
    grid on;
    hold off;

    % プロットの保存や表示に関する処理
    saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\07210729cape\', ['plot_' num2str(time_index) '.png']));

    % 図を閉じる
    close(gcf);
end
