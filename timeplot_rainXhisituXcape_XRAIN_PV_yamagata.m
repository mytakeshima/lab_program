% 時系列プロット
figure;

% 比湿プロット
yyaxis left;
plot(time_axis, q_avg, '-g', 'LineWidth', 1.5);
ylabel('比湿 (kg/kg)');

% CAPEプロット
hold on;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);

% CAPEの軸ラベルを追加
yyaxis left;
ylabel('比湿 (kg/kg), CAPE (J/kg)');

% DLSプロット
plot(time_axis, dls_avg, '-m', 'LineWidth', 1.5);

% DLSの軸ラベルも含める（共通軸を用いて調整）
ylabel('比湿 (kg/kg), CAPE (J/kg), DLS (m/s)');

% 降水量プロット
yyaxis right;
plot(precip_times, precip_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');

xlabel('時間 (JST)');
title('比湿、CAPE、DLS、および降水量の時系列');
legend('比湿 (q)', 'CAPE', 'DLS', '降水量（体積）');
grid on;

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\plot\2024山形線状降水帯', '時系列プロット.png'));
