% -------------------------------
% خواندن فایل EJP
% -------------------------------
fid = fopen('E:\3027.ejp','r');  % مسیر فایل
if fid == -1
    error('فایل باز نشد');
end
data = fread(fid, inf, 'uint8');
fclose(fid);

% -------------------------------
% پیدا کردن رشته ASCII ELTEX UK
% -------------------------------
header_ascii = 'ELTEX UK';
header_bytes = uint8(header_ascii);

idx = strfind(data', header_bytes);
if isempty(idx)
    error('Header ELTEX UK پیدا نشد');
end

% انتهای رشته ELTEX UK
header_end = idx(1) + length(header_bytes) - 1;

% -------------------------------
% پیدا کردن شروع تصویر بعد از هدر
% -------------------------------
% فرض: داده تصویر از اولین بایتی که مقدار > 0x00 و != header است شروع می‌شود
% می‌توانیم از header_end + 1 شروع کنیم
% در همه فایل‌ها این ایندکس کار می‌کند
start_idx = header_end + 1;

% حذف دو بایت آخر (checksum)
img_data = data(start_idx : end - 2);

% -------------------------------
% مشخصات تصویر
% -------------------------------
bytes_per_row = 8;                  % هر سطر = 8 بایت
n_rows = floor(length(img_data)/bytes_per_row);

img_matrix = zeros(n_rows, bytes_per_row*8);

% -------------------------------
% تبدیل داده به بیت‌مپ
% -------------------------------
for r = 1:n_rows
    row_bits = [];
    base = (r-1)*bytes_per_row;
    for b = 1:bytes_per_row
        byte = img_data(base + b);
        bits = de2bi(byte,8,'left-msb');   % همان حالت درست قبلی
        row_bits = [row_bits bits];
    end
    img_matrix(r,:) = row_bits;
end

% -------------------------------
% نمایش تصویر
% -------------------------------
figure;
imshow(img_matrix,'InitialMagnification','fit');
colormap(gray(2));  % 0=سفید، 1=مشکی
axis on;

% -------------------------------
% نمایش متنی w / b (اختیاری)
% -------------------------------
for r = 1:n_rows
    str = strrep(strrep(num2str(img_matrix(r,:)),'1','b'),'0','w');
    disp(['Row ' num2str(r) ': ' str]);
end
