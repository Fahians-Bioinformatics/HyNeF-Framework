% ============================================
% جدول Intramodular Connectivity برای WGCNA (۱۰ اجرا)
% ============================================

clc;
clear;
close all;

% داده‌های ۱۰ اجرا برای WGCNA (Intramodular Connectivity)
data_wgcna = [0.542;
              0.612;
              0.523;
              0.635;
              0.581;
              0.598;
              0.567;
              0.549;
              0.578;
              0.548];

% محاسبه میانگین و انحراف معیار
mean_val = mean(data_wgcna);
std_val  = std(data_wgcna);

% ایجاد جدول
execution = (1:10)';
connectivity = data_wgcna;

T = table(execution, connectivity, ...
    'VariableNames', {'اجرا', 'Intramodular_Connectivity'});

% نمایش جدول
disp(' ');
disp('=== جدول Intramodular Connectivity برای WGCNA (۱۰ اجرا) ===');
disp(' ');
disp(T);

% نمایش میانگین و انحراف معیار
fprintf('\n----------------------------------------\n');
fprintf('میانگین Intramodular Connectivity: %.3f\n', mean_val);
fprintf('انحراف معیار: ±%.3f\n', std_val);
fprintf('----------------------------------------\n');

% ============================================
% ذخیره جدول در فایل Excel
% ============================================

execution_all = [execution; 11];
connectivity_all = [data_wgcna; mean_val];

T_all = table(execution_all, connectivity_all, ...
    'VariableNames', {'اجرا', 'Intramodular_Connectivity'});

filename = 'WGCNA_Intramodular_Connectivity_10runs.xlsx';
writetable(T_all, filename);
fprintf('\nجدول در فایل %s ذخیره شد.\n', filename);

% ============================================
% رسم نمودار
% ============================================

figure('Position', [100, 100, 800, 500]);

subplot(1,2,1);
bar(execution, data_wgcna, 'FaceColor', [0.2 0.4 0.8]);
hold on;
yline(mean_val, '--r', 'LineWidth', 2);
ylim([0.45 0.70]);
xlabel('شماره اجرا');
ylabel('Intramodular Connectivity');
title('Intramodular Connectivity برای WGCNA در ۱۰ اجرا');
legend({'مقدار هر اجرا', sprintf('میانگین = %.3f', mean_val)}, ...
    'Location', 'southeast');
grid on;

subplot(1,2,2);
hold on;
scatter(execution, data_wgcna, 60, 'filled', 'MarkerFaceColor', [0.2 0.4 0.8]);
errorbar(3, mean_val, std_val, 'r', 'LineWidth', 2, 'CapSize', 10);
xlim([0 11]);
ylim([0.45 0.70]);
xlabel('شماره اجرا');
ylabel('Intramodular Connectivity');
title('میانگین و انحراف معیار');
legend({'مقادیر هر اجرا', sprintf('میانگین = %.3f ± %.3f', mean_val, std_val)}, ...
    'Location', 'southeast');
grid on;