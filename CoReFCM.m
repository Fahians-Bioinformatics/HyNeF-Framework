% ============================================================
% الگوریتم پیشنهادی: ELM + FCM + GA (بهینه‌شده)
% با تابع هدف ترکیبی (J + Silhouette)
% ============================================================

clc; clear; close all;
rng(42);

% ============================================================
% مرحله 1: بارگذاری و نرمال‌سازی داده Iris
% ============================================================
disp('========================================');
disp('مرحله 1: بارگذاری و نرمال‌سازی داده');
disp('========================================');

filename = 'iris.data';

if ~exist(filename, 'file')
    error('فایل iris.data در پوشه جاری پیدا نشد.');
end

data = readtable(filename, 'ReadVariableNames', false, 'FileType', 'text');
data.Properties.VariableNames = {'SepalLength', 'SepalWidth', 'PetalLength', 'PetalWidth', 'Species'};

X = data{:, 1:4};
species = data.Species;
unique_species = unique(species);
y_true = zeros(height(data), 1);
for i = 1:length(unique_species)
    y_true(strcmp(species, unique_species{i})) = i - 1;
end

% نرمال‌سازی Min-Max
X_min = min(X);
X_max = max(X);
X_norm = (X - X_min) ./ (X_max - X_min);

[n, k] = size(X_norm);
m = 3;                  % تعداد خوشه‌ها
L = 50;                 % تعداد نرون‌های لایه پنهان ELM
n_runs = 30;            % تعداد اجراها
max_generations = 200;  % افزایش نسل‌های GA
pop_size = 100;         % افزایش جمعیت GA
alpha = 0.6;            % وزن ترکیب J و Silhouette

% ============================================================
% مرحله 2: 30 بار اجرای الگوریتم پیشنهادی
% ============================================================
disp('========================================');
fprintf('مرحله 2: اجرای %d بار الگوریتم پیشنهادی (ELM+FCM+GA)\n', n_runs);
fprintf('تنظیمات: L=%d, Generations=%d, Population=%d, α=%.2f\n', L, max_generations, pop_size, alpha);
disp('========================================');

SR_all = zeros(n_runs, 1);
RM_all = zeros(n_runs, 1);
Sil_all = zeros(n_runs, 1);
J_all = zeros(n_runs, 1);
time_all = zeros(n_runs, 1);

for run = 1:n_runs
    fprintf('اجرای شماره %d از %d...\n', run, n_runs);
    tic;
    
    % ====== مرحله 2.1: محاسبه H (خروجی لایه پنهان ELM) ======
    W = rand(L, k) * 2 - 1;
    b = rand(L, 1) * 2 - 1;
    H = 1 ./ (1 + exp(-(X_norm * W' + b')));
    
    % ====== مرحله 2.2: بهینه‌سازی با GA (β و θ) ======
    n_vars = (L * m) + (k * m);
    lb = -1 * ones(1, n_vars);
    ub = 1 * ones(1, n_vars);
    
    options = optimoptions('ga', ...
        'PopulationSize', pop_size, ...
        'MaxGenerations', max_generations, ...
        'Display', 'off', ...
        'UseParallel', false, ...
        'PlotFcn', []);
    
    % تابع هدف ترکیبی
    fitness_func = @(chrom) compute_fitness(chrom, X_norm, H, n, m, k, L, alpha);
    
    [best_chrom, best_fitness] = ga(fitness_func, n_vars, [], [], [], [], lb, ub, [], options);
    
    % استخراج β و θ
    beta = reshape(best_chrom(1:L*m), [L, m]);
    theta = reshape(best_chrom(L*m+1:end), [k, m]);
    
    % ====== مرحله 2.3: محاسبه U ======
    U_raw = H * beta;
    U = U_raw ./ sum(U_raw, 2);
    
    % ====== مرحله 2.4: تخصیص قطعی به خوشه‌ها ======
    [~, y_pred] = max(U, [], 2);
    y_pred = y_pred - 1;
    
    % ====== مرحله 2.5: محاسبه معیارها ======
    % SR
    SR_all(run) = sum(y_pred == y_true) / n * 100;
    
    % RM
    cc = 0; dd = 0;
    for i = 1:n
        for j = i+1:n
            if (y_pred(i) == y_pred(j)) && (y_true(i) == y_true(j))
                cc = cc + 1;
            elseif (y_pred(i) ~= y_pred(j)) && (y_true(i) ~= y_true(j))
                dd = dd + 1;
            end
        end
    end
    total_pairs = n * (n - 1) / 2;
    RM_all(run) = (cc + dd) / total_pairs * 100;
    
    % Silhouette
    D = pdist2(X_norm, X_norm);
    sil = zeros(n, 1);
    for i = 1:n
        cluster_i = y_pred(i);
        same_cluster_idx = find(y_pred == cluster_i);
        if length(same_cluster_idx) > 1
            a = mean(D(i, same_cluster_idx(same_cluster_idx ~= i)));
        else
            a = 0;
        end
        
        b = inf;
        for c = 0:max(y_pred)
            if c == cluster_i
                continue;
            end
            other_idx = find(y_pred == c);
            if ~isempty(other_idx)
                b_tmp = mean(D(i, other_idx));
                if b_tmp < b
                    b = b_tmp;
                end
            end
        end
        
        if a < b
            sil(i) = 1 - a / b;
        elseif a > b
            sil(i) = b / a - 1;
        else
            sil(i) = 0;
        end
    end
    Sil_all(run) = mean(sil);
    
    % محاسبه J نهایی
    J = 0;
    for i = 1:n
        for j = 1:m
            d = norm(X_norm(i, :)' - theta(:, j));
            J = J + (U(i, j)^2) * d^2;
        end
    end
    J_all(run) = J;
    
    time_all(run) = toc;
end

% ============================================================
% مرحله 3: محاسبه آمار نهایی
% ============================================================
disp('========================================');
disp('مرحله 3: محاسبه آمار نهایی');
disp('========================================');

SR_mean = mean(SR_all);
SR_std = std(SR_all);
RM_mean = mean(RM_all);
RM_std = std(RM_all);
Sil_mean = mean(Sil_all);
Sil_std = std(Sil_all);
J_mean = mean(J_all);
J_std = std(J_all);
time_mean = mean(time_all);
time_std = std(time_all);

fprintf('\n========== نتایج نهایی پس از %d بار اجرا ==========\n', n_runs);
fprintf('نرخ موفقیت (SR):       %.2f ± %.2f %%\n', SR_mean, SR_std);
fprintf('اندازه رند (RM):        %.2f ± %.2f %%\n', RM_mean, RM_std);
fprintf('ضریب سیلیویت (Silhouette): %.4f ± %.4f\n', Sil_mean, Sil_std);
fprintf('تابع هدف نهایی (J):     %.4f ± %.4f\n', J_mean, J_std);
fprintf('زمان اجرا (ثانیه):      %.2f ± %.2f\n', time_mean, time_std);

% نمایش نتایج هر اجرا
fprintf('\n========== نتایج هر اجرا ==========\n');
fprintf('اجرا |   SR (%)   |   RM (%)   | Silhouette |   J    | زمان\n');
fprintf('-----|------------|------------|------------|--------|------\n');
for run = 1:n_runs
    fprintf(' %2d  |   %6.2f   |   %6.2f   |   %6.4f   | %6.4f | %5.2f\n', ...
        run, SR_all(run), RM_all(run), Sil_all(run), J_all(run), time_all(run));
end

% ============================================================
% مرحله 4: رسم نمودارها
% ============================================================
disp('========================================');
disp('مرحله 4: رسم نمودارها');
disp('========================================');

% Boxplot
figure('Name', ['Boxplot معیارها - روش پیشنهادی (L=', num2str(L), ')'], 'NumberTitle', 'off');
subplot(1, 3, 1);
boxplot(SR_all, 'Labels', {'SR'});
ylabel('درصد');
title('نرخ موفقیت');
grid on;

subplot(1, 3, 2);
boxplot(RM_all, 'Labels', {'RM'});
ylabel('درصد');
title('اندازه رند');
grid on;

subplot(1, 3, 3);
boxplot(Sil_all, 'Labels', {'Silhouette'});
ylabel('مقدار');
title('ضریب سیلیویت');
grid on;

% نمودار میله‌ای با انحراف معیار
figure('Name', 'میانگین معیارها - روش پیشنهادی', 'NumberTitle', 'off');
metrics = [SR_mean, RM_mean, Sil_mean * 100];
errors = [SR_std, RM_std, Sil_std * 100];
bar(metrics);
hold on;
errorbar(1:3, metrics, errors, 'k.', 'LineWidth', 1.5, 'MarkerSize', 20);
set(gca, 'XTickLabel', {'SR (%)', 'RM (%)', 'Silhouette (x100)'});
ylabel('مقدار');
title('میانگین معیارهای ارزیابی با انحراف معیار');
grid on;
hold off;

% ============================================================
% مرحله 5: ذخیره نتایج
% ============================================================
save('proposed_optimized_results.mat', 'SR_all', 'RM_all', 'Sil_all', 'J_all', 'time_all', ...
                         'SR_mean', 'SR_std', 'RM_mean', 'RM_std', 'Sil_mean', 'Sil_std');

csvwrite('proposed_SR_opt.csv', SR_all);
csvwrite('proposed_RM_opt.csv', RM_all);
csvwrite('proposed_Sil_opt.csv', Sil_all);

fprintf('\n========================================\n');
fprintf('✅ نتایج ذخیره شد:\n');
fprintf('1. proposed_optimized_results.mat\n');
fprintf('2. proposed_SR_opt.csv\n');
fprintf('3. proposed_RM_opt.csv\n');
fprintf('4. proposed_Sil_opt.csv\n');
fprintf('========================================\n');

% ============================================================
% تابع هدف ترکیبی (J + Silhouette)
% ============================================================
function fitness = compute_fitness(chrom, X, H, n, m, k, L, alpha)
    % استخراج β و θ
    beta = reshape(chrom(1:L*m), [L, m]);
    theta = reshape(chrom(L*m+1:end), [k, m]);
    
    % محاسبه U
    U_raw = H * beta;
    U = U_raw ./ sum(U_raw, 2);
    
    % ---- 1. محاسبه J (فشردگی) ----
    J = 0;
    for i = 1:n
        for j = 1:m
            d = norm(X(i, :)' - theta(:, j));
            J = J + (U(i, j)^2) * d^2;
        end
    end
    
    % ---- 2. محاسبه Silhouette (جدایی) ----
    [~, y_pred] = max(U, [], 2);
    y_pred = y_pred - 1;
    D = pdist2(X, X);
    sil = zeros(n, 1);
    for i = 1:n
        cluster_i = y_pred(i);
        same_cluster_idx = find(y_pred == cluster_i);
        if length(same_cluster_idx) > 1
            a = mean(D(i, same_cluster_idx(same_cluster_idx ~= i)));
        else
            a = 0;
        end
        
        b = inf;
        for c = 0:max(y_pred)
            if c == cluster_i, continue; end
            other_idx = find(y_pred == c);
            if ~isempty(other_idx)
                b_tmp = mean(D(i, other_idx));
                if b_tmp < b
                    b = b_tmp;
                end
            end
        end
        
        if a < b
            sil(i) = 1 - a / b;
        elseif a > b
            sil(i) = b / a - 1;
        else
            sil(i) = 0;
        end
    end
    Sil = mean(sil);
    
    % ---- 3. تابع هدف ترکیبی ----
    % کمینه‌سازی: alpha*J + (1-alpha)*(1-Sil)
    fitness = alpha * J + (1 - alpha) * (1 - Sil);
end