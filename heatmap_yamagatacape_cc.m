% ボツ

% 必要なデータの読み込み
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape'); % CAPEデータ
cloud_data = ncread('202407210729UTmodel_cloud.nc', 'cc'); % 雲量データ
lat = ncread('202407210729UTmodel_cape.nc', 'latitude');
lon = ncread('202407210729UTmodel_cape.nc', 'longitude');

% 緯度・経度範囲の指定
lat_range = [37 41];
lon_range = [139 142];
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% データ抽出範囲の設定
full_start_time = datenum(2024, 7, 20, 0, 0, 0);
start_time = datenum(2024, 7, 21, 0, 0, 0); % 開始日時
end_time = datenum(2024, 7, 28, 8, 0, 0);   % 終了日時

% 1時間のインデックス換算
time_step = 1 / 24; % 1時間 = 1日の1/24

% 開始と終了のインデックスを算出
start_idx = round((start_time - full_start_time) / time_step) + 1;
end_idx = round((end_time - full_start_time) / time_step) + 1;

% rest of the code continues

% % 日本地図の読み込み
% japan_map = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp');

% 各時間ステップに対するプロット
for time_index = start_idx:end_idx
    % CAPEと雲量のスライスを取得
    cape_slice = cape_data(lon_idx, lat_idx, time_index);
    cloud_slice = cloud_data(lon_idx, lat_idx, time_index);
    
    % 図の作成
    figure;
    
    % CAPEのヒートマップ
    subplot(1, 2, 1);
    imagesc(lon(lon_idx), lat(lat_idx), cape_slice');
    set(gca, 'YDir', 'normal');
    colorbar;
    title(['CAPE - ' datestr(full_start_time + hours(time_index - 1), 'yyyy/mm/dd HH:MM')]);
    xlabel('経度');
    ylabel('緯度');
    % hold on;
    % % 日本地図のプロット
    % mapshow(japan_map, 'Color', 'k', 'LineWidth', 1.5);
    % hold off;

    % 雲量のヒートマップ
    subplot(1, 2, 2);
    imagesc(lon(lon_idx), lat(lat_idx), cloud_slice');
    set(gca, 'YDir', 'normal');
    colorbar;
    title(['雲量 - ' datestr(full_start_time + hours(time_index - 1), 'yyyy/mm/dd HH:MM')]);
    xlabel('経度');
    ylabel('緯度');
    % hold on;
    % % 日本地図のプロット
    % mapshow(japan_map, 'Color', 'k', 'LineWidth', 1.5);
    % hold off;
    
    % 保存する場合
    saveas(gcf, fullfile('path_to_save_directory', ['plot_' datestr(full_start_time + hours(time_index - 1), 'yyyymmdd_HHMM') '.png']));
    close(gcf);
end
