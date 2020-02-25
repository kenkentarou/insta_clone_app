# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  avatar                  :string(255)
#  crypted_password        :string(255)
#  email                   :string(255)      not null
#  notification_on_comment :boolean          default(TRUE)
#  notification_on_follow  :boolean          default(TRUE)
#  notification_on_like    :boolean          default(TRUE)
#  salt                    :string(255)
#  username                :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

require 'rails_helper'
RSpec.describe User, type: :model do
  describe "バリデーション" do
    # ユーザー名が必須であること
    it 'ユーザー名は必須であること' do
      user = build(:user, username: nil)
      user.valid?
      expect(user.errors[:username]).to include('を入力してください')
    end
    # ユーザー名が一意であること
    it 'ユーザー名は一意であること' do
      user = create(:user)
      same_name_user = build(:user, username: user.username)
      same_name_user.valid?
      expect(same_name_user.errors[:username]).to include('はすでに存在します')
    end
    # メールアドレスが必須であること
    it 'メールアドレスは必須であること' do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include('を入力してください')
    end
    # メールアドレスが一意であること
    it 'メールアドレスは一意であること' do
      user = create(:user)
      same_email_user = build(:user, email: user.email)
      same_email_user.valid?
      expect(same_email_user.errors[:email]).to include('はすでに存在します')
    end
  end
  describe 'インスタンスメソッド' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:user_c) { create(:user) }
    let(:post_by_user_a) { create(:post, user: user_a) }
    let(:post_by_user_b) { create(:post, user: user_b) }
    let(:post_by_user_c) { create(:post, user: user_c) }
    # own?
    describe 'own?' do
      context '自分のオブジェクトの場合' do
        it 'trueを返す' do
          expect(user_a.own?(post_by_user_a)).to be true
        end
      end
      context '自分以外のオブジェクトの場合' do
        it 'falseを返す' do
          expect(user_a.own?(post_by_user_b)).to be false
        end
      end
    end
    # like
    describe 'like' do
      it 'いいねできること' do
        expect { user_a.like(post_by_user_b) }.to change { Like.count }.by(1)
      end
    end
    # unlike
    describe 'unlike' do
      it 'いいねを解除できること' do
        user_a.like(post_by_user_b)
        expect { user_a.unlike(post_by_user_b) }.to change { Like.count }.by(-1)
      end
    end
    # following?
    describe 'following?' do
      context 'フォローしている場合' do
        it 'trueを返す' do
          user_a.follow(user_b)
          expect(user_a.following?(user_b)).to be true
        end
      end
      context 'フォローしていない場合' do
        it 'falseを返す' do
          expect(user_a.following?(user_b)).to be false
        end
      end
    end
    # feed
    describe 'feed' do
      it '自分の投稿が含まれること' do
        expect(user_a.feed).to include post_by_user_a
      end
      it 'フォローしているユーザーの投稿が含まれること' do
        user_a.follow(user_b)
        expect(user_a.feed).to include post_by_user_b
      end
      it 'フォローしていないユーザーの投稿は含まれないこと' do
        expect(user_a.feed).not_to include post_by_user_c
      end
    end
  end
end