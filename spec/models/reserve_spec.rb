RSpec.describe Reserve, type: :model do
  it { is_expected.to validate_presence_of :plan_id }
  it { is_expected.to validate_presence_of :total_bill }
  it { is_expected.to validate_numericality_of :total_bill }
  it { is_expected.to validate_presence_of :term }
  it { is_expected.to validate_presence_of :head_count }
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_presence_of :contact }
  it { is_expected.to validate_length_of(:comment).is_at_most(140) }
  it { is_expected.to validate_inclusion_of(:contact).in_array(['no', 'email', 'tel'])}

  context 'when contact is email' do
    subject { Reserve.new(contact: 'email') }
    it { is_expected.to validate_presence_of :email }

    context 'when email format valid' do
      let(:reserve_email_valid) { Reserve.new(contact: 'email', email: 'example@example.com') }
      it 'error message not contained' do
        reserve_email_valid.valid?
        expect(reserve_email_valid.errors[:email]).to eq []
      end
    end

    context 'when email format invalid' do
      let(:reserve_email_valid) { Reserve.new(contact: 'email', email: '@') }
      it 'error message contained' do
        reserve_email_valid.valid?
        expect(reserve_email_valid.errors[:email]).to include 'is not an email'
      end
    end
  end

  context 'when contact is tel' do
    subject { Reserve.new(contact: 'tel') }
    it 'validation of tel is enable' do
      is_expected.to validate_presence_of :tel
      is_expected.to validate_length_of(:tel).is_equal_to(11)
    end
  end

  describe 'date' do
    it { is_expected.to validate_presence_of :date }

    context 'when date is today' do
      let(:reserve_date_valid) { Reserve.new(date: Date.today) }
      it 'be valid' do
        reserve_date_valid.valid?
        expect(reserve_date_valid.errors[:date]).to eq []
      end
    end

    context 'when date is 1day ago' do
      let(:reserve_date_invalid) { Reserve.new(date: Date.today - 1) }
      it 'be invalid' do
        reserve_date_invalid.valid?
        expect(reserve_date_invalid.errors[:date]).to include(include('must be greater than or equal to'))
      end
    end

    context 'when date is 3months later' do
      let(:reserve_3months_later) { Reserve.new(date: Date.new(2023, 2, 4)) }
      it 'be valid' do
        travel_to Date.new(2022, 12, 4) # 現在日付を変更
        reserve_3months_later.valid?
        expect(reserve_3months_later.errors[:date]).to eq []
      end
    end

    context 'when date is 3months + 1day later' do
      let(:reserve_3months_1day_later) { Reserve.new(date: Date.new(2023, 3, 5)) }
      it 'be invalid' do
        travel_to Date.new(2022, 12, 4) # 現在日付を変更
        reserve_3months_1day_later.valid?
        expect(reserve_3months_1day_later.errors[:date]).to include(include('must be less than or equal to'))
      end
    end

    context 'when current date is August 31' do
      it 'be valid if the date is November 30' do
        travel_to Date.new(2022, 8, 31) # 現在日付を変更
        reserve = Reserve.new(date: Date.new(2022, 11, 30))
        reserve.valid?
        expect(reserve.errors[:date]).to eq []
      end

      it 'be invalid if the date is December 1' do
        travel_to Date.new(2022, 8, 31) # 現在日付を変更
        reserve = Reserve.new(date: Date.new(2022, 12, 1))
        reserve.valid?
        expect(reserve.errors[:date]).to include(include('must be less than or equal to'))
      end
    end

    describe 'leap year' do
      context 'when 3months later is the end of February in leap year' do
        it 'be valid if the date is February 29' do
          travel_to Date.new(2023, 11, 30) # 現在日付を変更
          reserve = Reserve.new(date: Date.new(2024, 2, 29))
          reserve.valid?
          expect(reserve.errors[:date]).to eq []
        end

        it 'be invalid if the date is March 1' do
          travel_to Date.new(2023, 11, 30) # 現在日付を変更
          reserve = Reserve.new(date: Date.new(2024, 3, 1))
          reserve.valid?
          expect(reserve.errors[:date]).to include(include('must be less than or equal to'))
        end
      end
    end
  end

  describe 'validate_term' do
    context 'when between plan.min_term and plan.max_term' do
      let(:reserve_within_term_range) { Reserve.new(plan_id: 7, term: 3) }
      it 'be valid' do
        reserve_within_term_range.valid?
        expect(reserve_within_term_range.errors[:term]).to eq []
      end
    end

    context 'when not between plan.min_term and plan.max_term' do
      let(:reserve_without_term_range) { Reserve.new(plan_id: 7, term: 4) }
      it 'be invalid' do
        reserve_without_term_range.valid?
        expect(reserve_without_term_range.errors[:term]).to include('term is not in range')
      end
    end
  end

  describe 'validate_head_count' do
    context 'when between plan.min_head_count and plan.max_head_count' do
      let(:reserve_within_head_count_range) { Reserve.new(plan_id: 6, head_count: 6) }
      it 'be valid' do
        reserve_within_head_count_range.valid?
        expect(reserve_within_head_count_range.errors[:head_count]).to eq []
      end
    end

    context 'when not between plan.min_head_count and plan.min_head_count' do
      let(:reserve_without_head_count_range) { Reserve.new(plan_id: 6, head_count: 7) }
      it 'be invalid' do
        reserve_without_head_count_range.valid?
        expect(reserve_without_head_count_range.errors[:head_count]).to include('head_count is not in range')
      end
    end
  end

  describe 'end_date' do
    it 'end_date is date of reserves.date + reserves.term' do
      reserve = Reserve.new(date: Date.parse('2022-02-28'), term: 3)
      expect(reserve.end_date).to eq Date.parse('2022-03-03')
    end
  end

  describe 'validate_total_bill' do
    shared_examples 'valid when the total_bill is correct' do |params|
      it 'error message of total_bill does not contained' do
        reserve = Reserve.new(plan_id: 0, date: stay_date, **params)
        reserve.valid?
        expect(reserve.errors[:total_bill]).to_not include('must be equal to')
      end
    end

    context 'when valid value' do
      context 'when weekdays only' do
        let(:stay_date) { Date.parse('2020-02-03') } # monday

        context 'when not additional plans' do
          include_examples 'valid when the total_bill is correct', { term: 1, head_count: 1, total_bill: 7_000 }
          include_examples 'valid when the total_bill is correct', { term: 2, head_count: 1, total_bill: 14_000 }
          include_examples 'valid when the total_bill is correct', { term: 1, head_count: 2, total_bill: 14_000 }
          include_examples 'valid when the total_bill is correct', { term: 2, head_count: 2, total_bill: 28_000 }
          include_examples 'valid when the total_bill is correct', { term: 3, head_count: 3, total_bill: 63_000 }
        end

        context 'when include additional plans' do
          include_examples 'valid when the total_bill is correct', {
            term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true, total_bill: 9_000
          }
          include_examples 'valid when the total_bill is correct', {
            term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false, total_bill: 15_000
          }
          include_examples 'valid when the total_bill is correct', {
            term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false, total_bill: 18_000
          }
          include_examples 'valid when the total_bill is correct', {
            term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true, total_bill: 32_000
          }
          include_examples 'valid when the total_bill is correct', {
            term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true, total_bill: 78_000
          }
        end
      end

      context 'when include saturday or sanday' do
        let(:stay_date) { Date.parse('2020-02-08') } # saturday

        context 'when not additional plans' do
          include_examples 'valid when the total_bill is correct', { term: 1, head_count: 1, total_bill: 8_750 }
          include_examples 'valid when the total_bill is correct', { term: 2, head_count: 1, total_bill: 17_500 }
          include_examples 'valid when the total_bill is correct', { term: 1, head_count: 2, total_bill: 17_500 }
          include_examples 'valid when the total_bill is correct', { term: 2, head_count: 2, total_bill: 35_000 }
          include_examples 'valid when the total_bill is correct', { term: 3, head_count: 3, total_bill: 73_500 }
        end

        context 'when include additional plans' do
          include_examples 'valid when the total_bill is correct', {
            term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true, total_bill: 10_750
          }
          include_examples 'valid when the total_bill is correct', {
            term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false, total_bill: 18_500
          }
          include_examples 'valid when the total_bill is correct', {
            term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false, total_bill: 21_500
          }
          include_examples 'valid when the total_bill is correct', {
            term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true, total_bill: 39_000
          }
          include_examples 'valid when the total_bill is correct', {
            term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true, total_bill: 88_500
          }
        end
      end
    end

    context 'when invalid value' do
      it 'include error massage' do
        reserve = Reserve.new(plan_id: 0, date: Date.parse('2022-11-28'), term: 1, head_count: 1, total_bill: 111)
        reserve.valid?
        expect(reserve.errors[:total_bill]).to contain_exactly(match(/^must be equal to.*/))
      end
    end
  end
end
