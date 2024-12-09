%% パラメータ設定
% データディレクトリのベースパス
base_dir = 'C:\Users\murqk\Desktop\JTLN0720~0729\2024\07\';
addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス

% 時間設定
start_time = datetime(2024, 7, 20, 0, 0, 0); % データ開始時刻
end_time = datetime(2024, 7, 29, 23, 50, 00); % データ終了時刻
time_step = hours(1); % 時間ステップ (1時間)

% 緯度経度の範囲
lat_range = [38.5, 39.5]; % 緯度範囲
lon_range = [139.5, 140.5]; % 経度範囲

% 時間軸作成
time_axis = start_time:time_step:end_time;
num_time_steps = length(time_axis) - 1; % 時間区間数

% 結果保存用変数
lightning_counts = zeros(num_time_steps, 1); % 時間ごとの雷の個数

%% データ処理
for t = 1:num_time_steps
    % 現在の時間区間
    curr_time = time_axis(t);
    next_time = time_axis(t + 1);
    
    % 対応するディレクトリを構築
    curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));
    
    % JSONファイル名を構築
    file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
    json_file = fullfile(curr_date_dir, file_pattern);
    
    % JSONファイルが存在しない場合はスキップ
    if ~isfile(json_file)
        fprintf('File %s does not exist. Skipping...\n', json_file);
        continue;
    end
    
    % JSONファイルの読み込み
    [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
    
    % 緯度経度フィルタ
    lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
    lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);
    
    % 時間範囲内のデータをカウント
    valid_idx = lat_idx & lon_idx & (time >= curr_time & time < next_time);
    lightning_counts(t) = sum(valid_idx);
end

%% 時系列プロット
figure;
plot(time_axis(1:end-1) + minutes(30), lightning_counts, '-o', 'LineWidth', 1.5);
grid on;

% ラベルとタイトルを日本語で設定
xlabel('時間 (JST)', 'FontName', 'MS UI Gothic', 'FontSize', 14);
ylabel('雷の個数', 'FontName', 'MS UI Gothic', 'FontSize', 14);
title('緯度経度範囲内での雷の時系列', 'FontName', 'MS UI Gothic', 'FontSize', 16);

% 凡例を設定
legend({'雷の個数'}, 'FontName', 'MS UI Gothic', 'FontSize', 12, 'Location', 'Best');

% 軸フォントを統一
set(gca, 'FontName', 'MS UI Gothic', 'FontSize', 12);

%% 結果保存
output_file = fullfile('C:\Users\murqk\Desktop\plot', 'lightning_count_timeseries_fixed.png');
saveas(gcf, output_file);
fprintf('プロットを保存しました: %s\n', output_file);
