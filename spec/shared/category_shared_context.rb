require 'rails_helper'

RSpec.shared_context 'initialize subject and masks' do
  let(:inverse_favorite_token) do
    inverse = { 0 => 1, 1 => 0 }
    inverse[favorite_token]
  end
  subject(:subject_1) do
    create(:category_with_two_levels_subcategories_and_notes,
           favorite: inverse_favorite_token)
  end
  let(:category) { subject_1.subcategories.first }
  let(:notes_mask) do
    mask = {}
    subject_1.each do |category|
      next unless category.notes.any?

      category.notes.each do |note|
        mask[note.id] = inverse_favorite_token
      end
    end
    category.subcategories.each do |subcategory|
      subcategory.notes.each do |note|
        mask[note.id] = favorite_token
      end
    end
    mask.map { |k, v| [k, v.to_s] }.to_h
  end
  let(:categories_mask) do
    mask = {}
    subject.each do |category|
      mask[category.id] = inverse_favorite_token
    end
    mask[category.id] = favorite_token
    category.subcategories.each do |subcategory|
      mask[subcategory.id] = favorite_token
    end
    mask[category.parent_id] = 0 if favorite_token == 0
    mask.map { |k, v| [k, v.to_s] }.to_h
  end
end

RSpec.shared_context 'one category favorite status updated' do
  subject(:one_category_updated_favorite) do
    category.update_attribute(:favorite, favorite_token)
    category.update_related_items(favorite_token)
    subject_1.reload
  end
end

RSpec.shared_context 'two subcategories favorite status updated' do
  subject(:two_categories_updated_favorite) do
    category.subcategories.each do |subcategory|
      subcategory.update_attribute(:favorite, favorite_token)
      subcategory.update_related_items(favorite_token)
      subject_1.reload
    end
  end
end