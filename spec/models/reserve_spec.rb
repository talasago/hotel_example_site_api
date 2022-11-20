require 'rails_helper'

RSpec.describe Reserve, type: :model do
  it { is_expected.to validate_presence_of :plan_id }
  it { is_expected.to validate_presence_of :total_bill }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :term }
  it { is_expected.to validate_presence_of :head_count }
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_presence_of :contact }

  context 'contact is email' do
    subject { Reserve.new(contact: 'email') }
    it { is_expected.to validate_presence_of :email }
  end

  context 'contact is tel' do
    subject { Reserve.new(contact: 'tel') }
    it { is_expected.to validate_presence_of :tel }
  end

  it 'term_end is reserves.date + reserves.term' do
    reserve = Reserve.new(date: Date.parse('2022-02-28'), term: 3)
    expect(reserve.term_end).to eq Date.parse('2022-03-03')
  end

  describe 'total_bill' do
    let(:monday) { Date.parse('2020-02-02') }
    let(:saturday) { Date.parse('2020-02-07') }

    context 'only weekdays' do
      let(:reserve_monday) { Reserve.new(
        plan_id: 0,
        date: monday
      ) }

      it 'right calcurate total_bill' do
        aggregate_failures do
          #HACK: 共通化する関数あった方が良い
          reserve_monday.term = 1
          reserve_monday.head_count = 1
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 7_000

          reserve_monday.term = 2
          reserve_monday.head_count = 1
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 14_000

          reserve_monday.term = 1
          reserve_monday.head_count = 2
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 14_000

          reserve_monday.term = 2
          reserve_monday.head_count = 2
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 28_000

          reserve_monday.term = 3
          reserve_monday.head_count = 3
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 63_000

          reserve_monday.term = 1
          reserve_monday.head_count = 1
          reserve_monday.breakfast = true
          reserve_monday.early_check_in = false
          reserve_monday.sightseeing = true
          expect(reserve_monday.calc_total_bill).to eq 9_000

          reserve_monday.term = 2
          reserve_monday.head_count = 1
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = true
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 15_000

          reserve_monday.term = 1
          reserve_monday.head_count = 2
          reserve_monday.breakfast = true
          reserve_monday.early_check_in = true
          reserve_monday.sightseeing = false
          expect(reserve_monday.calc_total_bill).to eq 18_000

          reserve_monday.term = 2
          reserve_monday.head_count = 2
          reserve_monday.breakfast = false
          reserve_monday.early_check_in = true
          reserve_monday.sightseeing = true
          expect(reserve_monday.calc_total_bill).to eq 32_000

          reserve_monday.term = 3
          reserve_monday.head_count = 3
          reserve_monday.breakfast = true
          reserve_monday.early_check_in = true
          reserve_monday.sightseeing = true
          expect(reserve_monday.calc_total_bill).to eq 78_000
        end
      end
    end
  end
end
