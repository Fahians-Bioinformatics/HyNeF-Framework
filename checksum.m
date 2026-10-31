% داده‌ها
data = uint8([0x00, 0x7B, 0xC5, 0x71, 0x5C, 0x56, 0xF7, 0x00]);

% مقدار اولیه چک‌سام
checksum = uint16(0);

% محاسبه چک‌سام ساده 16 بیتی
for i = 1:length(data)
    checksum = checksum + uint16(data(i));
    checksum = bitand(checksum, uint16(65535)); % فقط 16 بیت
end

% نمایش چک‌سام به صورت هگز
checksum_hex = dec2hex(checksum, 4);
disp(['Checksum: 0x', checksum_hex]);
