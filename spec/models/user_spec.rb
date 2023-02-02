RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_length_of(:tel).is_equal_to(11).allow_nil }
  it { is_expected.to validate_inclusion_of(:rank).in_array(['premium', 'normal']) }
  it { is_expected.to validate_presence_of :gender }
  it { is_expected.to validate_inclusion_of(:gender).in_array([0, 1, 2, 9]) }

  describe 'email' do
    subject { User.new }
    it { is_expected.to validate_presence_of :email }

    context 'format valid' do
      #FIXME:FactoryBot使った方が良いかも
      let(:user) { User.new(email: 'example@example.com') }
      it {
        user.valid?
        expect(user.errors[:email]).to eq []
      }
    end

    context 'format invalid' do
      let(:user) { User.new(email: '@') }
      it {
        user.valid?
        expect(user.errors[:email]).to include 'is not an email'
      }
    end
  end
end
