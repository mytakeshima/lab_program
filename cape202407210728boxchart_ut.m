% データの読み込み
info = ncinfo('202407210729UTmodel_cape.nc');

data = ncread('202407210729UTmodel_cape.nc', 'cape');
lat = ncread('202407210729UTmodel_cape.nc', 'latitude'); % 緯度データ
lon = ncread('202407210729UTmodel_cape.nc', 'longitude'); % 経度データ

% プロットする緯度と経度の範囲を指定（例: 北緯35度〜40度、東経138度〜145度）
lat_range = [37 41];
lon_range = [139 142];

% 指定した範囲のインデックスを取得
lat_idx = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_idx = find(lon >= lon_range(1) & lon <= lon_range(2));

% 各日ごとの箱ひげ図を作成するための準備
start_time = datetime(2024, 7, 21, 0, 0, 0); % 開始日時
all_data = []; % すべてのデータを格納する配列
group_labels = []; % 各日ごとのラベルを格納

for day = 1:8
    % 現在の日付の時間ステップ範囲（1日=24時間分）
    time_indices = (day-1)*24 + (16:39);
    % 時差を考えると20日の15時のデータが21日の0時である。20日の0時から1時間ごとにデータをとっているので16番目のデータから使い始める
    
    % データを抽出し、範囲を指定して1次元に変換
    day_data = data(lon_idx, lat_idx, time_indices);
    day_data_vector = reshape(day_data, [], 1); % 1次元ベクトルに変換
    
    % データとグループラベルを保存
    all_data = [all_data; day_data_vector];
    group_labels = [group_labels; repmat(day, numel(day_data_vector), 1)];
end

% プロットの作成
figure;
boxchart(group_labels, all_data, 'BoxFaceColor', 'cyan');
xticks(1:8);
xticklabels(datestr(start_time + days(0:7), 'yyyy/mm/dd'));
xlabel('日付');
ylabel('CAPEの値');
%ylim([0 6000]); % 比較のための範囲固定
title('各日付ごとのCAPEの箱ひげ図 (指定範囲)');


% プロットの保存や表示に関する処理
    saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\07210729cape\', ['cape_boxcahart.png']));
