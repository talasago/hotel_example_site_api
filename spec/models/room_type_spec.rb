require 'rails_helper'

RSpec.describe RoomType, type: :model do
  describe 'room_category_type_name' do
    context "room_type_name isn't nil and room_category_name isn't nil" do
      let(:room_type) { RoomType.new(room_type_name: 'type', room_category_name: 'category') }

      it 'return room_type_name + room_category_name' do
        expect(room_type.room_category_type_name).to eq 'categorytype'
      end
    end

    context "room_type_name is nil and room_category_name isn't nil" do
      let(:room_type) { RoomType.new(room_category_name: 'category') }

      it 'return room_category_name' do
        expect(room_type.room_category_type_name).to eq 'category'
      end
    end
    context "room_type_name isn't nil and room_category_name is nil" do
      let(:room_type) { RoomType.new(room_type_name: 'type') }

      it 'return room_type_name' do
        expect(room_type.room_category_type_name).to eq 'type'
      end
    end

    context "room_type_name is nil and room_category_name is nil" do
      let(:room_type) { RoomType.new(room_type_name: 'type', room_category_name: 'category') }

      it 'return' do
        expect(room_type.room_category_type_name).to eq 'categorytype'
      end
    end
  end
end
