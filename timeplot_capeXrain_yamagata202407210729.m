% イベント情報
% 【気象の概況】
% ・梅雨前線に向かって暖かく湿った空気が流れ込んだため、7月24日から26日にかけて東北地方で大雨となり、25日に線状降水帯が発生し、山
% 形県内の市町村を対象に大雨特別警報を発表した。
% 【線状降水帯に関する情報の発表状況】
% ・線状降水帯による大雨の半日程度前からの呼びかけは実施しなかった。
% ・7月25日に山形県を対象に顕著な大雨に関する気象情報を発表した。
% 
% 顕著な大雨に関する気象情報
% 7月25日13時07分(庄内、最上)、3時間降水量約140ミリ
% 7月25日22時47分(村山、庄内、最上)、3時間降水量約130ミリ
% 


% データの読み込み
cape_data = ncread('202407210729UTmodel_cape.nc', 'cape'); % CAPEデータ
precip_data = ncread('202407210729UTmodel_rain.nc', 'tp'); % 降水量データ
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

% 抽出したデータの平均値を計算（時間軸で取得）
cape_avg = squeeze(mean(mean(cape_data(lon_idx, lat_idx, :), 1), 2));
precip_avg = squeeze(mean(mean(precip_data(lon_idx, lat_idx, :), 1), 2));

% 時間軸の設定（JSTに変換：UTC + 9時間）
time_start = datetime(2024, 7, 20, 0, 0, 0) + hours(9); % JSTに変更
time_step = hours(1); % 1時間ごと
time_axis = time_start + (0:length(cape_avg)-1) * time_step;

% CAPEと降水量の時系列プロット
figure;
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
xlabel('時間 (JST)');
title('時間ごとのCAPEと降水量');

yyaxis right;
plot(time_axis, precip_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量 (mm)');

legend('CAPE', '降水量');
grid on;

% プロットの保存や表示に関する処理
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\capeXrain時系列プロット', ['CAPEと降水量の折れ線グラフ.png']));
