require 'rails_helper'

RSpec.describe Reserve, type: :model do
  it { is_expected.to validate_presence_of :plan_id }
  it { is_expected.to validate_presence_of :total_bill }
  it { is_expected.to validate_numericality_of :total_bill }
  it { is_expected.to validate_presence_of :term }
  it { is_expected.to validate_presence_of :head_count }
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_presence_of :contact }

  context 'contact is email' do
    subject { Reserve.new(contact: 'email') }
    it { is_expected.to validate_presence_of :email }

    context 'format valid' do
      #FIXME:FactoryBot使った方が良いかも
      let(:reserve_email_valid) { Reserve.new(contact: 'email', email: 'example@example.com') }
      it {
        reserve_email_valid.valid?
        expect(reserve_email_valid.errors[:email]).to eq []
      }
    end

    context 'format invalid' do
      let(:reserve_email_valid) { Reserve.new(contact: 'email', email: '@') }
      it {
        reserve_email_valid.valid?
        expect(reserve_email_valid.errors[:email]).to include 'invalid email format'
      }
    end
  end

  context 'contact is tel' do
    subject { Reserve.new(contact: 'tel') }
    it {
      is_expected.to validate_presence_of :tel
      is_expected.to validate_length_of(:tel).is_equal_to(11)
    }
  end

  describe 'date' do
    it { is_expected.to validate_presence_of :date }

    context 'date is today' do
      #FIXME:FactoryBot使った方が良いかも
      let(:reserve_date_valid) { Reserve.new(date: Date.today) }
      it 'be valid' do
        reserve_date_valid.valid?
        expect(reserve_date_valid.errors[:date]).to eq []
      end
    end

    context 'date is 1day ago' do
      let(:reserve_date_invalid) { Reserve.new(date: Date.today - 1) }
      it 'be invalid' do
        reserve_date_invalid.valid?
        expect(reserve_date_invalid.errors[:date]).to include(include('must be greater than or equal to'))
      end
    end

    context 'date is 3months later' do
      let(:reserve_3months_later) { Reserve.new(date: Date.new(2023, 2, 4)) }
      it 'be valid' do
        travel_to Date.new(2022, 12, 4) # 現在日付を変更
        reserve_3months_later.valid?
        expect(reserve_3months_later.errors[:date]).to eq []
      end
    end

    context 'date is 3months + 1day later' do
      let(:reserve_3months_1day_later) { Reserve.new(date: Date.new(2023, 3, 5)) }
      it 'be invalid' do
        travel_to Date.new(2022, 12, 4) # 現在日付を変更
        reserve_3months_1day_later.valid?
        expect(reserve_3months_1day_later.errors[:date]).to include(include('must be less than or equal to'))
      end
    end

    context 'current date is August 31' do
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
      context '3months later is the end of February in leap year' do
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

  it 'term_end is reserves.date + reserves.term' do
    reserve = Reserve.new(date: Date.parse('2022-02-28'), term: 3)
    expect(reserve.term_end).to eq Date.parse('2022-03-03')
  end

  describe 'validate total_bill' do
    shared_examples 'Valid when the total_bill is correct' do |params|
      it {
        #FIXME:letの値をinclude_examplesで呼び出しているが、わかりづらくなくなるので変えた方が良い気が
        reserve = Reserve.new(plan_id: 0, date: stay_date, **params)
        reserve.valid?
        expect(reserve.errors[:total_bill]).to_not include('must be equal to')
      }
    end

    context 'valid' do
      context 'only weekdays' do
        let(:stay_date) { Date.parse('2020-02-03') } # monday

        context 'not additional plans' do
          include_examples 'Valid when the total_bill is correct', { term: 1, head_count: 1, total_bill: 7_000 }
          include_examples 'Valid when the total_bill is correct', { term: 2, head_count: 1, total_bill: 14_000 }
          include_examples 'Valid when the total_bill is correct', { term: 1, head_count: 2, total_bill: 14_000 }
          include_examples 'Valid when the total_bill is correct', { term: 2, head_count: 2, total_bill: 28_000 }
          include_examples 'Valid when the total_bill is correct', { term: 3, head_count: 3, total_bill: 63_000 }
        end

        context 'include additional plans' do
          include_examples 'Valid when the total_bill is correct', {
            term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true, total_bill: 9_000
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false, total_bill: 15_000
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false, total_bill: 18_000
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true, total_bill: 32_000
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true, total_bill: 78_000
          }
        end
      end

      context 'include saturday or sanday' do
        let(:stay_date) { Date.parse('2020-02-08') } # saturday

        context 'not additional plans' do
          include_examples 'Valid when the total_bill is correct', { term: 1, head_count: 1, total_bill: 8_750 }
          include_examples 'Valid when the total_bill is correct', { term: 2, head_count: 1, total_bill: 17_500 }
          include_examples 'Valid when the total_bill is correct', { term: 1, head_count: 2, total_bill: 17_500 }
          include_examples 'Valid when the total_bill is correct', { term: 2, head_count: 2, total_bill: 35_000 }
          include_examples 'Valid when the total_bill is correct', { term: 3, head_count: 3, total_bill: 73_500 }
        end

        context 'include additional plans' do
          include_examples 'Valid when the total_bill is correct', {
            term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true, total_bill: 10_750
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false, total_bill: 18_500
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false, total_bill: 21_500
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true, total_bill: 39_000
          }
          include_examples 'Valid when the total_bill is correct', {
            term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true, total_bill: 88_500
          }
        end
      end
    end

    context 'invalid' do
      it 'include error massage' do
        reserve = Reserve.new(plan_id: 0, date: Date.parse('2022-11-28'), term: 1, head_count: 1, total_bill: 111)
        reserve.valid?
        expect(reserve.errors[:total_bill]).to contain_exactly(match(/^must be equal to.*/))
      end
    end
  end
end
