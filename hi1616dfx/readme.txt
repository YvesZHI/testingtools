1.insmod dfx.ko����Ҫ��֤����ʱʹ���ں˺�ʹ�û����ں�ƥ�䣬�汾��һ��ʱ�����±��룩

2.���ò������������ͺͲ���ʱ�䣩����echo "1 10" > /proc/HI1616_DFX��ʽ���ã�1Ϊ���ͣ���ʾDDR��LLC��10��ʾʱ��Ϊ10�룬��������/home��
�������Ͷ������£�
���������ͣ����·��
1��DDR��LLC��/home/llc_ddr_statistic��
2��HHA��SLLC��/home/hha_sllc_statisticÿ��12�����ݣ���Ӧ12���¼���ͳ�ƽ���������������辭����ʽת����SLLC��ÿ��4�����ݣ���ʾTX��request��snoop��response��dataͨ��packet�����Ĵ���
3��AA read��/home/aa_rd_statistic
4��AA write��/home/aa_wr_statistic��
5: AA copyback��/home/aa_cb_statistic
6: PA��HLLC��/home/pa_statistic��

3.��������
python parse.py -c �������� -t ʱ��  -o ����ļ���

����������
1��aa_cb
2)aa_rd
3)aa_wr
4)hha
5)hllc
6)llc
7)pa
9)sllc
ʱ�䣺
��2�в���ʱ�䱣��һ��

4.�������������ʽ
���ͣ�������ݣ�����������ʽ
DDR��ÿ���������������������ΪDDR0 wr,DDR0 rd,DDR1 wr,DDR1 rd������������Ҫ��Ϊ����ͳ�ƣ�����DDR��ͳ�ƽ������32��ת��Ϊbyte/s����parse.py�����λΪMB/s
LLC��ÿ��8�����ݣ�ֻ���עǰ6������Ӧ�����б��е�6��ͳ�ƽ������������Ϊ��������4/(0+2)��д������5/(1+3)�������㹫ʽ�����ֱ�ʾ6��ͳ�ƽ������ţ�
HHA��ÿ��12�����ݣ���Ӧ12���¼���ͳ�ƽ���������������辭����ʽת��
SLLC��ÿ��4�����ݣ���ʾTX��request��snoop��response��dataͨ��packet�����Ĵ�������������Ҫ��Ϊ����ͳ�ƣ����ø���ͳ�ƽ������16��ת��Ϊbyte/s����parse.py�����λΪMB/s
AA��ÿ�а���4��AA����ʱ��ƽ����ʱ�����������������ʱ������ʱ��λΪcycle����������Ϊƽ����ʱ�������ʱ
PA��ÿ�а���RX��Hydra Port0��request��snoop��response��dataͨ��������Hydra Port1�ģ�Hydra port2�ġ����������������辭����ʽת��
HLLC��ÿ�а���8�����ݣ��ֱ�Ϊchannel0,1,2,3��PA���͸�HLLC��flit������channel0,1,2,3��HLLC����PA��flit��������������Ҫ��Ϊ����ͳ�ƣ����ø���ͳ�ƽ������16��ת��Ϊbyte/s����parse.py�����λΪMB/s

