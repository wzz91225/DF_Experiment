function [data_freqdomain,freqlist] = time_to_frequency_domain(data_timedomain,freq_samp)
% TIME_TO_FREQUENCY_DOMAIN ԭʼʱ������תƵ��

% �����ݳ���
L = length(data_timedomain);

% fft�����ֵ�볤���йأ��ʳ��Գ��ȣ����Ը�����������ֵ
d_fft = abs(fft(data_timedomain) / L);

% �����ο�˹��׼�򣬽�������Ч�ĵ�������
data_freqdomain = d_fft(1 : L/2+1);

% ��Ϊ�������ݺ��轫������ֵ�˶����õ����ֵƵ��
data_freqdomain(2 : end-1) = 2 * data_freqdomain(2 : end-1);

% ���ݲ���Ƶ�ʻ��Ƶ������
freqlist = freq_samp * (0 : L/2) / L;

end

