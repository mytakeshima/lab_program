% 10minutes
addpath 'C:\Users\murqk\Desktop\EN\' %（変更）
%% S1-1 --- Dataに雷についてのデータを保存 

dir = 'C:\Users\murqk\Desktop\2024\07\25\';       % JTLNデータのディレクトリを指定（変更）

Data = [];

for hr=12:14   %　JTLNデータの時刻指定(UT)（変更）
    for mn=0:10:50


        h = num2str(hr, '%02d');
        m = num2str(mn, '%02d');

        JJ = strcat('FLASHES_2024-07-25T', h, '-', m, '.json');%　FLASHES_YYYY-MM-DDTはディレクトリの日付を指定（変更）
        [time, type, latitude, longitude, height, amplitude, sgMultiplicity, HandM] = GetJson_test(strcat(dir, JJ));

        % make output table
        time = time';
        type = type';
        latitude = latitude';
        longitude = longitude';
        height = height';
        amplitude = amplitude';
        sgMultiplicity = sgMultiplicity';
        HandM = HandM';
        Data_temp = table(time, type, latitude, longitude, height, amplitude, sgMultiplicity, HandM);
        Data = [Data; Data_temp];

    end
end
%% 雷データをIC,+CG,-CGに分類わけ

% 分類わけをする際の条件（変更）
x_low_lon = 139;  % 経度
x_up_lon = 142;
y_low_lat = 37;  % 緯度
y_up_lat = 41;

idx3 = Data.latitude > y_low_lat & Data.latitude < y_up_lat;                   % latitude range
idx4 = Data.longitude > x_low_lon & Data.longitude < x_up_lon;                 % longitude range
idx5 = Data.type == 1;                                                       % IC condition
idx6 = Data.type == 0 & Data.amplitude <= 0;                                   % -CG condition
idx7 = Data.type == 0 & Data.amplitude > 0;                                    % +CG condition
idx8 = Data.type >= 0 & Data.type <= 1;

tbl_IC_all = Data( idx3 & idx4 & idx5, :);                                         % IC
tbl_nCG_all = Data( idx3 & idx4 & idx6,:);                                        %-CG%
tbl_pCG_all = Data(idx3 & idx4 & idx7,:);                                        %+CG%
tbl_TL_all = Data( idx3 & idx4 & idx8,:);                                         %TL%

%データの全体分類わけ終了
%% 
%% 本編

% xrainのデータディレクトリを指定（変更）
dir = 'C:\Users\murqk\Desktop\XRAIN\07\25\';

S = shaperead("C:\Users\murqk\Desktop\EN\JPN_adm1.shp");

% カスタムカラーマップの作成
cmap = jet;


% XRAINデータの座標系（変更）
latitude_range = [37, 41];
longitude_range = [139, 142];
rows = 1920;
cols = 960;

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
ylim1=41-(3*ylim_low/1920);
ylim2=41-(3*ylim_up/1920);

Rtable = table('Size', [0, 9], 'VariableTypes', {'datetime','double', 'double','double','double','double','double','double','double'}, ...
                     'VariableNames', {'JPTime','Time', 'num_IC','num_nCG','num_pCG','num_total','Total_Values','Total_Values2', 'Above_Threshold_Ratio'});


% プログラム開始（変更）
for xrain_hr = 21:23  %　XRAINデータの時刻指定JST（変更）
    for xrain_mn = 0:10:50
        %途中で始める場合はここを調整（変更）
        if xrain_hr==16 && xrain_mn<3
            continue;
        end

        %途中でやめる場合はここを調整（変更）
        if xrain_hr==16 && xrain_mn==30
            break;
        end


        xrain_h = num2str(xrain_hr, '%02d');
        xrain_m = num2str(xrain_mn, '%02d');

        xrain_file = strcat('20240725-', xrain_h, xrain_m, '.csv'); %　日付部分を（変更）
        xrain_path = fullfile(dir, xrain_file);

        % CSVファイルの読み込み
        data = readmatrix(xrain_path);

        % 0の位置を最小値に変換
        % min_val = min(data(data > 0));
        % data(data == 0) = min_val;
        
        figure;
        hold on;
        mapshow(S,'FaceColor','none');
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
        set(gca,'YDir','normal')
        xlim([xlim1, xlim2]);
        ylim([ylim2, ylim1]);
        % xlim([min(longitudes) max(longitudes)]);
        % ylim([min(latitudes) max(latitudes)]);



        % 時刻を表示（黒色）
        text(xlim2, ylim2, sprintf('%02d:%02d', xrain_hr, xrain_mn), 'Color', 'r', 'FontSize', 12,'VerticalAlignment','bottom','HorizontalAlignment','right');

        % 透明度の設定（透明度閾値以下は透明になります）（任意変更）
        alpha(h, double(data >0));

        % 閾値を超える部分の閉曲線の描画
        Thresholds = [50, 80, 120];
        colors = {'r', 'g', 'k'};
        for i = 1:length(Thresholds)
            [B, L] = bwboundaries(data > Thresholds(i), 'noholes');
            hold on;
            for k = 1:length(B)
                boundary = B{k};
                plot(longitudes(boundary(:, 2)), latitudes(boundary(:, 1)), colors{i}, 'LineWidth', 2);
            end
        end

        Thresholds = [120];
        colors = {'k'};
        for i = 1:length(Thresholds)
            [B, L] = bwboundaries(data > Thresholds(i), 'noholes');
            hold on;
            for k = 1:length(B)
                boundary = B{k};
                plot5 = plot(longitudes(boundary(:, 2)), latitudes(boundary(:, 1)), colors{i}, 'LineWidth', 2);
            end
        end
        hold on;

% % 一時的に停止
        % 大分類から１分ごとの小分類に雷を分類

        current_time = 2400 + xrain_hr*100 + xrain_mn - 900;
        JPTime = datetime(2023,7,25,xrain_hr,xrain_mn,0);   %　日付部分（変更）

        if current_time > 2400
            current_time = current_time-2400;
        end

        idx9  = (tbl_IC_all.HandM >= current_time) & (tbl_IC_all.HandM <= current_time + 9);
        idx10 = (tbl_nCG_all.HandM >= current_time) & (tbl_nCG_all.HandM <= current_time + 9);
        idx11 = (tbl_pCG_all.HandM >= current_time) & (tbl_pCG_all.HandM <= current_time + 9);
        idx12 = (tbl_TL_all.HandM >= current_time) & (tbl_TL_all.HandM <= current_time + 9);

        tbl_IC = tbl_IC_all(idx9 , :);                                         % IC
        tbl_nCG = tbl_nCG_all(idx10 ,:);                                        %-CG%
        tbl_pCG = tbl_pCG_all(idx11 ,:);                                        %+CG%
        tbl_TL = tbl_TL_all(idx12 ,:);                                         %TL%




        % tbl_IC のデータ
        plot2 = scatter(tbl_IC.longitude, tbl_IC.latitude,500, 'filled', 'Marker', '.','LineWidth',5, 'MarkerEdgeColor', [0 0 0]);
        hold on
        % tbl_nCG のデータ
        plot3 = scatter(tbl_nCG.longitude, tbl_nCG.latitude,100, 'filled', 'Marker', '_','LineWidth',2,'MarkerEdgeColor', [1 0 1]);
        hold on        
        % tbl_pCG のデータ
        plot4 = scatter(tbl_pCG.longitude, tbl_pCG.latitude,100, 'filled', 'Marker', '+', 'LineWidth',2,'MarkerEdgeColor', [1 0 0]);
        legend([plot2 plot3 plot4],{'IC','-CG','+CG'});
        
% 


        drawnow;

        hold off;
        
                % プロットの保存
        save_filename = strcat('xrain_plot_', xrain_h, xrain_m, '.png');  % 保存ファイル名を指定
        saveas(gcf, save_filename);  % 画像をPNGファイルとして保存

    end
end
