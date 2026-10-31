% ============================================
% جدول تراکم درون‌ماژولی برای WGCNA (۱۰ اجرا)
% ============================================

clc;
clear;
close all;

% داده‌های ۱۰ اجرا
data = [0.421;
        0.483;
        0.405;
        0.502;
        0.452;
        0.478;
        0.423;
        0.449;
        0.467;
        0.438];

% محاسبه میانگین و انحراف معیار
mean_val = mean(data);
std_val  = std(data);

% ایجاد جدول (بدون ستون روش)
execution = (1:10)';
density = data;

T = table(execution, density, ...
    'VariableNames', {'اجرا', 'تراکم_درون‌ماژولی'});

% نمایش جدول
disp(' ');
disp('=== جدول تراکم درون‌ماژولی WGCNA (۱۰ اجرا) ===');
disp(' ');
disp(T);

% نمایش میانگین و انحراف معیار
fprintf('\n----------------------------------------\n');
fprintf('میانگین تراکم درون‌ماژولی: %.3f\n', mean_val);
fprintf('انحراف معیار: ±%.3f\n', std_val);
fprintf('----------------------------------------\n');

% ============================================
% ذخیره جدول در فایل Excel
% ============================================

% ایجاد جدول کامل با سطر میانگین
execution_all = [execution; 11];
density_all = [data; mean_val];

T_all = table(execution_all, density_all, ...
    'VariableNames', {'اجرا', 'تراکم_درون‌ماژولی'});

% ذخیره در فایل Excel
filename = 'WGCNA_Module_Density_10runs.xlsx';
writetable(T_all, filename);
fprintf('\nجدول در فایل %s ذخیره شد.\n', filename);