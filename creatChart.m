% Data
elapsedTime = [4, 7.59, 6.608369, 1.4531, 2.4295, 0.7];
algorithmNames = {'FCM', 'FCM-PSO', 'Hierarchical', 'K-Means', 'K-Medoids', 'HSCCA'};

% Create Bar Chart
figure;
barHandle = bar(elapsedTime);
barHandle.FaceColor = '#0072BD'; % Set bar color
barHandle.EdgeColor = 'black';  % Set edge color
set(gca, 'XTickLabel', algorithmNames, 'XTickLabelRotation', 45); % Add x-tick labels
xlabel('Clustering Methods');
ylabel('Time (seconds)');

grid on;
set(gcf, 'Position', [100, 100, 800, 500]); % Set figure size

% Save Chart as JPG
saveas(gcf, 'ElapsedTimeChart.png');  % ذخیره به فرمت PNG
% یا برای وضوح بالا:
print('ElapsedTimeChart.png', '-dpng', '-r300');  % ذخیره به فرمت PNG با وضوح 300 dpi

