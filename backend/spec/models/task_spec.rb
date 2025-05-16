# spec/models/task_spec.rb
require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) do
    User.create!(
      name:     'テストユーザー',
      email:    "user#{SecureRandom.hex(4)}@example.com",
      password: 'password'
    )
  end

  let(:workspace) do
    Workspace.create!(
      name:        'テストワークスペース',
      description: 'テスト用'
    ).tap { |ws| WorkspaceUser.create!(workspace: ws, user: user) }
  end

  subject do
    described_class.new(
      title:     'タスクタイトル',
      content:   '詳細説明',
      status:    'pending',
      due_date:  Date.tomorrow,
      category:  'feature',
      workspace: workspace,
      user:      user
    )
  end

  it '有効なファクトリを持つこと' do
    expect(subject).to be_valid
  end

  context 'バリデーション' do
    it 'タイトルがなければ無効であること' do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it 'ステータスが不正なら無効であること' do
      subject.status = 'unknown'
      expect(subject).not_to be_valid
      expect(subject.errors[:status]).to include("is not included in the list")
    end

    it 'カテゴリが不正なら無効であること' do
      subject.category = 'invalid'
      expect(subject).not_to be_valid
      expect(subject.errors[:category]).to include("is not included in the list")
    end
  end
end
