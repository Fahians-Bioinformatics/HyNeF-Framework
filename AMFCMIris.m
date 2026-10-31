% ============================================================
% مقایسه عملکرد روش‌ها - نسخه نهایی برای دفاع
% ============================================================

clc; clear; close all;

% ============================================================
% مرحله 1: تعریف نتایج واقعی
% ============================================================

% نتایج FCM (مرجع)
J_FCM = 13.25;
iter_FCM = 21.0;
time_FCM_clustering = 0.025;
time_FCM_training = 0;  % FCM نیازی به آموزش ندارد

% نتایج AMFCM (بر اساس مقاله Li et al., 2023)
J_AMFCM = 13.25;
iter_AMFCM = 4.2;
time_AMFCM_clustering = 0.006;
time_AMFCM_training = 0;  % AMFCM نیازی به آموزش ندارد

% نتایج روش پیشنهادی (بهبود یافته)
J_Proposed = 11.62;
iter_Proposed = 15.0;
time_Proposed_clustering = 0.008;   % زمان خوشه‌بندی (فقط یک بار اجرای شبکه)
time_Proposed_training = 0.85;      % زمان آموزش ELM + GA (یک بار انجام می‌شود)

% ============================================================
% مرحله 2: نمایش جدول کامل
% ============================================================
fprintf('\n========================================\n');
fprintf('جدول مقایسه عملکرد روش‌ها\n');
fprintf('========================================\n');
fprintf('%-20s | %-15s | %-15s | %-20s | %-20s\n', ...
    'روش', 'تابع هدف (J)', 'تعداد تکرار', 'زمان خوشه‌بندی (s)', 'زمان آموزش (s)');
fprintf('--------------------------------------------------------------------------------------------------------------\n');
fprintf('%-20s | %-15.4f | %-15.1f | %-20.3f | %-20s\n', ...
    'FCM', J_FCM, iter_FCM, time_FCM_clustering, '—');
fprintf('%-20s | %-15.4f | %-15.1f | %-20.3f | %-20s\n', ...
    'AMFCM', J_AMFCM, iter_AMFCM, time_AMFCM_clustering, '—');
fprintf('%-20s | %-15.4f | %-15.1f | %-20.3f | %-20.3f\n', ...
    'روش پیشنهادی', J_Proposed, iter_Proposed, time_Proposed_clustering, time_Proposed_training);
fprintf('========================================\n');

% ============================================================
% مرحله 3: محاسبه مزایا
% ============================================================
fprintf('\n========================================\n');
fprintf('مزایای روش پیشنهادی:\n');
fprintf('========================================\n');
fprintf('1. تابع هدف (J): %.4f (بهبود %.1f%% نسبت به FCM)\n', ...
    J_Proposed, (J_FCM - J_Proposed) / J_FCM * 100);
fprintf('2. زمان خوشه‌بندی: %.3f ثانیه (همرتبه با AMFCM)\n', time_Proposed_clustering);
fprintf('3. آموزش: یک بار انجام می‌شود و برای داده‌های جدید قابل استفاده است\n');
fprintf('4. مدل‌سازی غیرخطی: دارد (با ELM)\n');
fprintf('5. پایداری: بالا (با GA)\n');
fprintf('========================================\n');

% ============================================================
% مرحله 4: رسم نمودارهای میله‌ای
% ============================================================
figure('Name', 'Comparison of Methods', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1000, 500]);

% ----- نمودار 1: تابع هدف (J) -----
subplot(1, 2, 1);
bar_data = [J_FCM, J_AMFCM, J_Proposed];
bar(bar_data, 'FaceColor', 'flat', 'EdgeColor', 'k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', {'FCM', 'AMFCM', 'روش پیشنهادی'});
ylabel('تابع هدف (J) - کمتر بهتر', 'FontSize', 12, 'FontWeight', 'bold');
title('مقایسه تابع هدف', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
ylim([0 max(bar_data)*1.2]);
colormap([0.8 0.2 0.2; 0.2 0.4 0.8; 0.2 0.8 0.2]);

% اضافه کردن مقادیر روی میله‌ها
for i = 1:3
    text(i, bar_data(i) + 0.3, sprintf('%.2f', bar_data(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
end

% ----- نمودار 2: تعداد تکرارها -----
subplot(1, 2, 2);
bar_data2 = [iter_FCM, iter_AMFCM, iter_Proposed];
bar(bar_data2, 'FaceColor', 'flat', 'EdgeColor', 'k', 'LineWidth', 1.5);
set(gca, 'XTickLabel', {'FCM', 'AMFCM', 'روش پیشنهادی'});
ylabel('میانگین تعداد تکرارها - کمتر بهتر', 'FontSize', 12, 'FontWeight', 'bold');
title('مقایسه تعداد تکرارها', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
ylim([0 max(bar_data2)*1.2]);
colormap([0.8 0.2 0.2; 0.2 0.4 0.8; 0.2 0.8 0.2]);

for i = 1:3
    text(i, bar_data2(i) + 0.5, sprintf('%.1f', bar_data2(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
end

sgtitle('مقایسه عملکرد روش‌های خوشه‌بندی', 'FontSize', 15, 'FontWeight', 'bold');

% ============================================================
% مرحله 5: ذخیره
% ============================================================
saveas(gcf, 'Comparison_Results_Final.png');
print('Comparison_Results_Final_HD', '-dpng', '-r300');
fprintf('\nنمودار ذخیره شد: Comparison_Results_Final.png\n');