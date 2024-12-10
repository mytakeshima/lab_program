


% 60minutes
addpath 'C:\Users\murqk\Desktop\EN\' %（変更）
%% S1-1 --- Dataに雷についてのデータを保存 

dir = 'C:\Users\murqk\Desktop\2024\07\';       % JTLNデータのディレクトリを指定（変更）

Data = [];


%% 
%% 本編

% xrainのデータディレクトリを指定（変更）
dir = 'C:\Users\murqk\Desktop\XRAIN山形\60mn\07\';

S = shaperead("C:\Users\murqk\Desktop\EN\JPN_adm1.shp");

% カスタムカラーマップの作成
cmap = jet;


% XRAINデータの座標系（変更）
latitude_range = [37, 41];
longitude_range = [139, 142];
% rows = 1920;
% cols = 960;

rows = 480;  % 行数の更新 CSVファイルの大きさに対応させた。
cols = 320;  % 列数の更新

% データの緯度経度座標を計算
latitudes = linspace(latitude_range(1), latitude_range(2), rows);
longitudes = linspace(longitude_range(1), longitude_range(2), cols);
latitudes = fliplr(latitudes);

% プロット表示範囲（変更）

xlim_low=0; % x軸下限(max0)
xlim_up=960;% x軸上限(max960)
ylim_low=0;% y軸上限(max0)
ylim_up=1920;% y軸下限(max1920)

xlim1=139+(3*xlim_low/960);
xlim2=139+(3*xlim_up/960);
ylim1=41-(4*ylim_low/1920);
ylim2=41-(4*ylim_up/1920);

Rtable = table('Size', [0, 9], 'VariableTypes', {'datetime','double', 'double','double','double','double','double','double','double'}, ...
                     'VariableNames', {'JPTime','Time', 'num_IC','num_nCG','num_pCG','num_total','Total_Values','Total_Values2', 'Above_Threshold_Ratio'});


% プログラム開始（変更）
% ファイルがない時間があるのでエラーの可能性あり
for xrain_day = 20:29
    for xrain_hr = 0:23  % XRAINデータの時刻指定JST（変更）
        xrain_day_str = num2str(xrain_day, '%02d');
        xrain_h_str = num2str(xrain_hr, '%02d');

        xrain_file = fullfile('C:\Users\murqk\Desktop\XRAIN山形\60mn\07', ...
        sprintf('202407%02d-%02d00.csv', xrain_day, xrain_hr));
    
    if ~exist(xrain_file, 'file')
        fprintf('File %s does not exist. Skipping...\n', xrain_file);
        continue;
    end

        % % ファイル名を指定
        % xrain_file = strcat('202407', xrain_day_str, '-', xrain_h_str, '00.csv'); 
        % xrain_path = fullfile(dir, xrain_file);

        %xrain_path = fullfile(dir, xrain_file);

        % CSVファイルの読み込み
        data = readmatrix(xrain_file);

        figure;
        hold on;
        mapshow(S, 'FaceColor', 'none');
        grid on;

        % 画像のプロット
        h = imagesc(longitudes, latitudes, data);
        colormap(cmap);
        shading interp;
        title('Grid Data Visualization');
        xlabel('Longitude');
        ylabel('Latitude');
        colorbar;
        clim([0 80]);
        set(gca, 'YDir', 'normal')
        xlim([xlim1, xlim2]);
        ylim([ylim2, ylim1]);

        % 時刻を表示（黒色）
        timestamp = sprintf('07/%02d %02d:00', str2double(xrain_day_str), str2double(xrain_h_str));
        text(xlim2, ylim2, timestamp, 'Color', 'r', 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

        % 透明度の設定
        alpha(h, double(data > 0));

        drawnow;
        hold off;

        % プロットの保存
        save_filename = fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯\XRAIN(LT)\', strcat('xrain_plot_', xrain_day_str, '_', xrain_h_str, '00.png'));
        saveas(gcf, save_filename);  % 画像をPNGファイルとして保存
    end
end
