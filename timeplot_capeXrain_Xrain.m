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

% % XRAINデータの読み込みと平均値計算
% precip_avg = [];
% precip_times = datetime.empty;
% 
% for t = 0:num_time_steps-1
%     xrain_time = time_start + t * time_step;
%     xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN\10mn\07', sprintf('202407%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
% 
%     if ~exist(xrain_file, 'file')
%         fprintf('File %s does not exist. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     % CSVファイルの読み込み
%     data = readmatrix(xrain_file);
%     precip_avg(end+1) = mean(data(:)); % ファイル内のデータを全て平均化
%     precip_times(end+1) = xrain_time; % 存在するファイルの時間のみを保存
% end
% 
% % CAPEと降水量の時系列プロット
% figure;
% yyaxis left;
% plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
% ylabel('CAPE (J/kg)');
% xlabel('時間 (JST)');
% title('時間ごとのCAPEと降水量');
% 
% % 降水量のプロット（存在する時刻データのみ）
% % 降水量の平均値の値がマイナスになっている！！おかしい！！
% yyaxis right;
% plot(precip_times, precip_avg, '-r', 'LineWidth', 1.5);
% ylabel('降水量 (m)');
% 
% legend('CAPE', '降水量');
% grid on;
% 
% 
% % プロットの保存や表示に関する処理
% saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\capeXrain時系列プロット', ['CAPEと降水量の折れ線グラフ.png']));

% XRAINデータの読み込みと平均値計算
precip_avg = [];
precip_times = datetime.empty;

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
    
    % 有効なデータの平均値を計算
    precip_avg(end+1) = mean(valid_data);
    precip_times(end+1) = xrain_time; % 存在するファイルの時間のみを保存
end

% CAPEと降水量の時系列プロット
figure;
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
xlabel('時間 (JST)');
title('時間ごとのCAPEと降水量');

% 降水量のプロット（存在する時刻データのみ）
yyaxis right;
plot(precip_times, precip_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量 (m)');

legend('CAPE', '降水量');
grid on;

% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\capeXrain時系列プロット', 'CAPEと降水量の折れ線グラフ改.png'));