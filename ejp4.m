% فایل را باز کن
fid = fopen('E:\3027.ejp','r');
data = fread(fid, inf, 'uint8'); % همه بایت‌ها
fclose(fid);

% الگوی ثابت برای پیدا کردن نقطه شروع (چهار بایت اول)
pattern = [0xF7, 0x00, 0x00, 0xDE];
pattern_len = length(pattern);

% پیدا کردن ایندکس شروع
start_idx = [];
for i = 1:length(data)-pattern_len+1
    if all(data(i:i+pattern_len-1)' == pattern)
        start_idx = i;
        break;
    end
end

if isempty(start_idx)
    error('الگو در فایل پیدا نشد.');
end

% از نقطه شروع تا انتهای فایل
data_from_start = data(start_idx:end);

% تعداد سطرها با 8 بایت در هر سطر
n_bytes_per_row = 8;
n_rows = floor(length(data_from_start)/n_bytes_per_row);

% ماتریس بیت‌ها
img_matrix = zeros(n_rows, n_bytes_per_row*8); % هر سطر 64 بیت

for r = 1:n_rows
    row_bits = [];
    for b = 1:n_bytes_per_row
        byte = data_from_start((r-1)*n_bytes_per_row + b);
        bits = de2bi(byte, 8, 'left-msb'); % بیت‌های هر بایت
        row_bits = [row_bits bits];
    end
    img_matrix(r,:) = row_bits;
end

% نمایش تصویری
figure;
imshow(img_matrix, 'InitialMagnification','fit');
colormap(gray(2));
axis on;

% نمایش متنی w/b
for r = 1:n_rows
    str = strrep(strrep(num2str(img_matrix(r,:)), '1','b'),'0','w');
    disp(['Row ' num2str(r) ': ' str]);
end
