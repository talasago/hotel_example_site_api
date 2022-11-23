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
    shared_examples 'right calcurate total_bill' do |params, expect|
      it {
        reserve = Reserve.new(
          plan_id: 0,
          date: stay_date,
          **params
        )
        expect(reserve.calc_total_bill).to eq expect
      }
    end

    context 'only weekdays' do
      let(:stay_date) { Date.parse('2020-02-03') } # monday

      context 'not additional plans' do
        include_examples 'right calcurate total_bill', { term: 1, head_count: 1 }, 7_000
        include_examples 'right calcurate total_bill', { term: 2, head_count: 1 }, 14_000
        include_examples 'right calcurate total_bill', { term: 1, head_count: 2 }, 14_000
        include_examples 'right calcurate total_bill', { term: 2, head_count: 2 }, 28_000
        include_examples 'right calcurate total_bill', { term: 3, head_count: 3 }, 63_000
      end

      context 'include additional plans' do
        include_examples 'right calcurate total_bill', {
          term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true
        }, 9_000
        include_examples 'right calcurate total_bill', {
          term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false
        }, 15_000
        include_examples 'right calcurate total_bill', {
          term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false
        }, 18_000
        include_examples 'right calcurate total_bill', {
          term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true
        }, 32_000
        include_examples 'right calcurate total_bill', {
          term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true
        }, 78_000
      end
    end

    context 'include saturday or sanday' do
      let(:stay_date) { Date.parse('2020-02-08') } # saturday

      context 'not additional plans' do
        include_examples 'right calcurate total_bill', { term: 1, head_count: 1 }, 8_750
        include_examples 'right calcurate total_bill', { term: 2, head_count: 1 }, 17_500
        include_examples 'right calcurate total_bill', { term: 1, head_count: 2 }, 17_500
        include_examples 'right calcurate total_bill', { term: 2, head_count: 2 }, 35_000
        include_examples 'right calcurate total_bill', { term: 3, head_count: 3 }, 73_500
      end

      context 'include additional plans' do
        include_examples 'right calcurate total_bill', {
          term: 1, head_count: 1, breakfast: true, early_check_in: false, sightseeing: true
        }, 10_750
        include_examples 'right calcurate total_bill', {
          term: 2, head_count: 1, breakfast: false, early_check_in: true, sightseeing: false
        }, 18_500
        include_examples 'right calcurate total_bill', {
          term: 1, head_count: 2, breakfast: true, early_check_in: true, sightseeing: false
        }, 21_500
        include_examples 'right calcurate total_bill', {
          term: 2, head_count: 2, breakfast: false, early_check_in: true, sightseeing: true
        }, 39_000
        include_examples 'right calcurate total_bill', {
          term: 3, head_count: 3, breakfast: true, early_check_in: true, sightseeing: true
        }, 88_500
      end
    end
  end
end
