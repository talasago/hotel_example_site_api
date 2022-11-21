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
    context 'only weekdays' do
      #HACK:頑張ったけど普通に関数の方が良いかも。letの値を渡せるならば。
      shared_examples 'right calcurate total_bill' do |hash, expect|
        reserve_monday = Reserve.new(
          plan_id: 0,
          date: Date.parse('2020-02-02'),
          **hash
        )
        it { expect(reserve_monday.calc_total_bill).to eq expect }
      end

      include_examples 'right calcurate total_bill', {
        term: 1, head_count: 1, breakfast: false, early_check_in: false, sightseeing: false
      }, 7_000
      include_examples 'right calcurate total_bill', {
        term: 2, head_count: 1, breakfast: false, early_check_in: false, sightseeing: false
      }, 14_000
      include_examples 'right calcurate total_bill', {
        term: 1, head_count: 2, breakfast: false, early_check_in: false, sightseeing: false
      }, 14_000
      include_examples 'right calcurate total_bill', {
        term: 2, head_count: 2, breakfast: false, early_check_in: false, sightseeing: false
      }, 28_000
      include_examples 'right calcurate total_bill', {
        term: 3, head_count: 3, breakfast: false, early_check_in: false, sightseeing: false
      }, 63_000

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
end
