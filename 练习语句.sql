--1.��ѯ" 01 "�γ̱�" 02 "�γ̳ɼ��ߵ�ѧ������Ϣ���γ̷���
select s.*,sc.cid,sc.score from student s,sc where sc.sid=s.sid and s.sid in (
select t1.sid from 
(select * from sc where CId='01') t1,
(select * from sc where CId='02') t2
where t1.SId=t2.SId and t1.score>t2.score )
--����һ�ֺ�Щ
select * from Student RIGHT JOIN (
    select t1.SId, class1, class2 from
          (select SId, score as class1 from sc where sc.CId = '01')as t1, 
          (select SId, score as class2 from sc where sc.CId = '02')as t2
    where t1.SId = t2.SId AND t1.class1 > t2.class2
)r 
on Student.SId = r.SId;
--1.1 ��ѯͬʱ����" 01 "�γ̺�" 02 "�γ̵����
select t1.*,t2.* from 
(select * from sc where CId='01') t1,
(select * from sc where CId='02') t2
where t1.SId=t2.SId
--1.2 ��ѯ����" 01 "�γ̵����ܲ�����" 02 "�γ̵����(������ʱ��ʾΪ null )
select t1.*,t2.* from 
(select * from sc where CId='01') t1 left join
(select * from sc where CId='02') t2
on t1.SId=t2.SId
--1.3 ��ѯ������" 01 "�γ̵�����" 02 "�γ̵����
select * from sc where SId not in 
(select SId from sc where CId='01') and CId='02'
--2��ѯƽ���ɼ����ڵ��� 60 �ֵ�ͬѧ��ѧ����ź�ѧ��������ƽ���ɼ�
select SId,avg(score) avg_score from sc group by SId having avg(score) >= '60'
 
select t1.*,st.Sname from 
(select SId,avg(score) avg_score from sc group by SId having avg(score) >= '60') t1,
student st
 where 
st.SId=t1.SId order by avg_score desc;
--3.��ѯ�� SC ����ڳɼ���ѧ����Ϣ
select st.* from student st where exists (select 1 from sc where sc.SId=st.SId);
select * from student where SId in (select distinct SId from sc);
--4.��ѯ����ͬѧ��ѧ����š�ѧ��������ѡ�����������пγ̵��ܳɼ�(û�ɼ�����ʾΪ null )
select s.SId,s.Sname,count(sc.CId),sum(sc.score) from student s left join sc on sc.SId=s.SId group by SId
--4.1 ���гɼ���ѧ����Ϣ   the same as question 3
select s.* from student s where exists (select 1 from sc where sc.SId=s.SId);
--5.��ѯ�������ʦ������
select count(*) cnt from teacher where Tname like '��%';
--6.��ѯѧ������������ʦ�ڿε�ͬѧ����Ϣmysql�ֶβ����ִ�Сд
select s.* from student s ,sc,course c where sc.SId=s.SId and c.CId = sc.CId and c.TId = (select TId from teacher where Tname='����')
--7.��ѯû��ѧȫ���пγ̵�ͬѧ����Ϣ  ת������sc�����¼��С��3,����Ҫע�������sc����û�м�¼��
select s.* from student s ,sc where s.sid=sc.sid group by s.sid having count(sc.CId)<3 --����,ֻ���������
select * from student where student.sid not in 
(select sc.sid from sc group by sc.sid having count(sc.cid)=(select count(distinct cid) from course))
--8.��ѯ������һ�ſ���ѧ��Ϊ" 01 "��ͬѧ��ѧ��ͬ��ͬѧ����Ϣ
select s.* from student s ,sc where s.sid=sc.sid and sc.cid in (select sc.cid from sc where sid='01') group by s.sid
--����
select * from student 
where student.sid in (
    select sc.sid from sc 
    where sc.cid in(
        select sc.cid from sc 
        where sc.sid = '01'
    )
);
--9.*��ѯ��" 01 "�ŵ�ͬѧѧϰ�Ŀγ���ȫ��ͬ������ͬѧ����Ϣ  �����е��Ѷ�
select * from student where sid in 
(select sid from sc where sid not in
(select sid from sc where cid not in (select cid from sc where sid='01')) --������01ͬѧû�����е�ͬѧ
group by sid 
having count(*)=(select count(*) from sc where sid='01')) --��01���еĿγ���һ���࣬��������һ�������ж�
and sid != '01';
--10.��ѯûѧ��"����"��ʦ���ڵ���һ�ſγ̵�ѧ������
select * from student where sid not in(
select sid from sc where cid = (select c.cid from course c ,teacher t where c.tid=t.tid and t.tname='����'))
--11.��ѯ���ż������ϲ�����γ̵�ͬѧ��ѧ�ţ���������ƽ���ɼ�  �ҵĴ�����count(sc.score<60) >1  count�������У���������,�����õ�����ƴ��,Ȼ��having����һ���ͳ�Ƶ�
select s.*,avg(sc.score) avg_score from student s,sc where s.sid=sc.sid and sc.score<60  group by sid having count(*)>1
--12.����" 01 "�γ̷���С�� 60���������������е�ѧ����Ϣ
select s.*,sc.score from student s,sc where sc.sid=s.sid and sc.score<60 and sc.cid='01' order by sc.score desc
--13��ƽ���ɼ��Ӹߵ�����ʾ����ѧ�������пγ̵ĳɼ��Լ�ƽ���ɼ�  �����˼·���ˣ�ÿ�ŵĿγ̿ɵ����У����sc������ƽ���ֵ�������
select * from sc left join 
(select sid,avg(score) avg_score from sc group by sid) a on a.sid=sc.sid 
order by a.avg_score desc
--14.��ѯ���Ƴɼ���߷֡���ͷֺ�ƽ���֣�
select cid,max(score),min(score),avg(score) from sc group by cid
--����  ��������ʽ��ʾ���γ� ID���γ� name����߷֣���ͷ֣�ƽ���֣������ʣ��е��ʣ������ʣ�������
--����Ϊ>=60���е�Ϊ��70-80������Ϊ��80-90������Ϊ��>=90
--Ҫ������γ̺ź�ѡ����������ѯ����������������У���������ͬ�����γ̺���������
select cid,max(score) ��߷�,min(score) ��ͷ�,avg(score) ƽ���� ,count(*) ѡ�޸ÿγ�����,
sum(case when score>=60 then 1 else 0 end)/count(*) as ������,
sum(case when score>=70 and score<80 then 1 else 0 end)/count(*) as �е���,
sum(case when score>=80 and score<90 then 1 else 0 end)/count(*) as ������,
sum(case when score>=90 then 1 else 0 end)/count(*) as ������
from sc group by cid 
order by count(*)  desc,cid asc--��������ǰ�����ȼ���
--15.�����Ƴɼ��������򣬲���ʾ������ Score �ظ�ʱ�������ο�ȱ
--�����е��Ѷ�
select a.cid,a.sid,a.score,count(b.score)+1 as rank
from sc a left join sc b
on a.score<b.score and a.cid=b.cid
group by a.cid,a.sid,a.score
order by a.cid,rank asc;
--16.��ѯѧ�����ܳɼ����������������ܷ��ظ�ʱ���������ο�ȱ
--������Ҫѧϰһ��ʹ�ñ�������SQL���������@����ʶ��:=�����ĸ�ֵ
set @crank=0;
select q.sid,q.total,@crank := @crank +1 as rank from (
select sc.sid,sum(sc.score) as total from sc group by sc.sid order by total desc) q
--17.ͳ�Ƹ��Ƴɼ����������������γ̱�ţ��γ����ƣ�[100-85]��[85-70]��[70-60]��[60-0] ����ռ�ٷֱ�
select sc.cid,c.cname,count(*) ������,
sum(case when sc.score>=85 then 1 else 0 end )/count(*) '[100-85]',
sum(case when sc.score>=70 and sc.score<85 then 1 else 0 end )/count(*) '[85-70]',
sum(case when sc.score>=60 and sc.score<70 then 1 else 0 end )/count(*) '[70-60]',
sum(case when sc.score<60 then 1 else 0 end )/count(*) '[60-0]'
 from sc,course c where 
sc.cid=c.cid group by sc.cid
--18.��ѯ���Ƴɼ�ǰ�����ļ�¼ 
--˼·1������Լ�������ļ�¼�м��������С��3 ��select
select * from sc where (
select count(*) from sc as a where a.cid=sc.cid and sc.score<a.score) <3
order by cid asc,sc.score desc;
--19.��ѯÿ�ſγ̱�ѡ�޵�ѧ����
select cid,count(sid) from sc group by cid
--20.��ѯ��ֻѡ�����ſγ̵�ѧ��ѧ�ź�����
--���ϲ�ѯ
select s.sid,s.sname from student s,sc where sc.sid=s.sid group by s.sid having count(sc.cid)='2' 
--Ƕ�ײ�ѯ
select sid,sname from student where sid in
(select sid from sc group by sid having count(sc.cid)=2);
--21.��ѯ������Ů������
select ssex,count(*) from student group by ssex
--22.��ѯ�����к��С��硹�ֵ�ѧ����Ϣ
select * from student where sname like '%��%'
--23.��ѯͬ��ѧ����������ͳ��ͬ������
select s.sname,count(*) from student s group by sname having count(*)>1
--24.��ѯ 1990 �������ѧ������
select * from student where sage like '1990%';
select * from student where YEAR(student.Sage)=1990;--���ڸ�ʽȡyear month day  time 
--25.��ѯÿ�ſγ̵�ƽ���ɼ��������ƽ���ɼ��������У�ƽ���ɼ���ͬʱ�����γ̱����������
select sc.cid,c.cname,avg(score) from sc,course c where sc.cid=c.cid group by sc.cid order by avg(sc.score) desc,sc.cid
--26.��ѯƽ���ɼ����ڵ��� 85 ������ѧ����ѧ�š�������ƽ���ɼ�
select s.sid,s.sname,avg(sc.score) from student s,sc where s.sid=sc.sid group by s.sid having avg(sc.score)>='85'
--27.��ѯ�γ�����Ϊ����ѧ�����ҷ������� 60 ��ѧ�������ͷ���
select s.sname,a.score from student s ,
(select sid,score from sc where cid=(select cid from course where cname='��ѧ') and score <60) a
where s.sid=a.sid
--28.��ѯ����ѧ���Ŀγ̼��������������ѧ��û�ɼ���ûѡ�ε������
select s.sname,sc.cid,sc.score from student s left join sc on s.sid=sc.sid
--29.��ѯ�κ�һ�ſγ̳ɼ��� 70 �����ϵ��������γ����ƺͷ���
select s.sname,c.cname,sc.score from student s,sc,course c where s.sid=sc.sid and sc.cid=c.cid and sc.score>70
--30.��ѯ���ڲ�����Ŀγ�       ������group by ��ȡΨһ��Ҳ������distinct
select cid from sc group by cid having min(score)<60
select DISTINCT CId from sc where score <60;
--31.��ѯ�γ̱��Ϊ 01 �ҿγ̳ɼ��� 80 �ּ����ϵ�ѧ����ѧ�ź�����
select s.sid,s.sname,sc.score from student s,sc where sc.cid='01' and s.sid=sc.sid and sc.score>=80
--32.��ÿ�ſγ̵�ѧ������
select cid,count(sid) from sc group by cid 
--33.�ɼ����ظ�����ѯѡ�ޡ���������ʦ���ڿγ̵�ѧ���У��ɼ���ߵ�ѧ����Ϣ����ɼ�
select s.*,sc.score  from student s,sc where s.sid=sc.sid and sc.cid=
(select c.cid from course c,teacher t where c.tid=t.tid and t.tname='����')
order by sc.score desc limit 1
    --����
select student.*, sc.score, sc.cid from student, teacher, course,sc 
where teacher.tid = course.tid
and sc.sid = student.sid
and sc.cid = course.cid
and teacher.tname = "����"
having max(sc.score);
--34.�ɼ����ظ�������£���ѯѡ�ޡ���������ʦ���ڿγ̵�ѧ���У��ɼ���ߵ�ѧ����Ϣ����ɼ�
--˼·�ǲ�ѯ��߷֣�Ȼ���ٲ�ѯ������߷ֵ�
--35.��ѯ��ͬ�γ̳ɼ���ͬ��ѧ����ѧ����š��γ̱�š�ѧ���ɼ�
select sc1.* from sc sc1,sc sc2 where sc1.cid<>sc2.cid and sc1.score=sc2.score and sc1.sid=sc2.sid group by sc1.sid,sc1.cid
--36.��ѯÿ�ųɼ���õ�ǰ����   �������   ����
select a.* from sc a left join sc b 
on a.cid=b.cid and a.sid=b.sid order by a.cid,a.score desc

select a.sid,a.cid,a.score from sc as a left join sc as b on a.cid = b.cid and a.score<b.score
group by a.cid, a.sid
having count(b.cid)<2
order by a.cid;
--37.ͳ��ÿ�ſγ̵�ѧ��ѡ������������ 5 �˵Ŀγ̲�ͳ�ƣ�
select cid,count(sid) rs from sc group by cid having rs>5 
--38.��������ѡ�����ſγ̵�ѧ��ѧ��
select sid,count(cid) from sc group by sid having count(cid)>='2'
--39.��ѯѡ����ȫ���γ̵�ѧ����Ϣ
select s.* from student s,sc where sc.sid=s.sid group by sc.sid having count(cid)=(select count(distinct(cid)) from sc); 
--40.��ѯ��ѧ�������䣬ֻ���������
select sname,(year(now())-year(sage)) from student 
--41.���ճ����������㣬��ǰ���� < �������µ������������һ
select student.SId as ѧ�����,student.Sname  as  ѧ������,TIMESTAMPDIFF(YEAR,student.Sage,CURDATE()) as ѧ������ from student
--42.��ѯ���ܹ����յ�ѧ��
select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE());
--43.��ѯ���ܹ����յ�ѧ��
select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE())+1;
--44.��ѯ���¹����յ�ѧ��
select * from student where MONTH(student.Sage)=MONTH(CURDATE());
--45.��ѯ���¹����յ�ѧ��
select *from student where MONTH(student.Sage)=MONTH(CURDATE())+1;



