require 'rails_helper'

RSpec.describe Reserve, type: :model do
  it { is_expected.to validate_presence_of :plan_id }
  it { is_expected.to validate_presence_of :total_bill }
  it { is_expected.to validate_numericality_of :total_bill }
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

  describe 'validate total_bill' do
    shared_examples 'Valid when the total_bill is correct' do |params|
      it {
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
