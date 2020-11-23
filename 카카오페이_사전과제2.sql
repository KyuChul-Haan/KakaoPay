-- 카카오페이 사전과제2

/*

더치페이를 요청한 유저 중 a 가맹점에서 2019년 12월에 1만원 이상 결제한 유저를 대상으로 리워드를 지급하려고 합니다. 리워드 지급 대상자 user_id를 추출하는 SQL 쿼리를 작성해주세요.
- 2019년 12월 결제분 중 취소를 반영한 순결제금액 1만원 이상인 유저만을 대상으로 함
- 취소 반영기간은 2020년 2월까지로 함

*/

--Query
	select distinct a.user_id as user_id --중복없는 지워드 지급 대상자 user_id 
	from 
	(
		select p1.user_id, sum(p1.amount-isnull(p2.amount,0)) as amount --유저별 결제금액 (전체 취소를 다 하지 않은 건도 있어서 결제와 취소 금액을 뺌)
		from
		(
			select transaction_id, user_id, amount
			from a_payment_trx
			where payment_action_type='PAYMENT' --a가맹점에서 결제
				and transacted_at>='2019-12-01' --2019년 12월
				and transacted_at<='2019-12-31'
		) as p1
		left outer join 
		(
			select transaction_id, user_id, amount
			from a_payment_trx
			where payment_action_type='CANCEL' --a가맹점에서 결제 취소 
				and transacted_at>='2019-12-01' 
				and transacted_at<='2020-02-29' --2020년 2월까지
		) as p2
		on p1.transaction_id=p2.transaction_id 
			and p1.user_id=p2.user_id
		group by 1
	) as a
	left outer join 
	(
		select claim_id, claim_user_id --더치페이 요청 유저
		from dutchpay_claim
	) as b
	on a.user_id=b.claim_user_id
	where b.claim_id is not null
        and amount>=10000 --a가맹점 순결제금액이 1만원 이상