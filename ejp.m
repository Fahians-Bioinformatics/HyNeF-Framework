% داده‌ها به صورت بایت (Hex)
data = [...
    0x00 0x7B 0xC5 0x71 0x5C 0x56 0xF7 0x00; ...
    0x00 0xDE 0xDC 0x57 0x15 0xC7 0xBD 0x00; ...
    0x00 0xF7 0x95 0xC5 0x71 0x5D 0xEF 0x00];

[n_rows, n_bytes] = size(data);

% ماتریس بیت‌ها
img_matrix = zeros(n_rows, n_bytes*8); % 3x64

for r = 1:n_rows
    row_bits = [];
    for b = 1:n_bytes
        bits = de2bi(data(r,b),8,'left-msb');
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
