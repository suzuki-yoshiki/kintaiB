class Attendance < ApplicationRecord
  belongs_to :user
  
  enum mark_instructor_confirmation: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  enum mark_change_confirmation: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  enum mark_apploval_confirmation: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }  , _prefix: true
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_before_at_is_invalid_without_a_started_before_at
 
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  validate :confirmation_mark_finished_at_without_started_at_both 
  
  def finished_before_at_is_invalid_without_a_started_before_at
    errors.add(:started_before_at, "が必要です") if started_before_at.blank? && finished_before_at.present?
  end
  
  def confirmation_mark_finished_at_without_started_at_both 
    if started_before_at.present? && finished_before_at.present?
      errors.add(:change_confirmation, "が必要です") if change_confirmation.blank?
    end
  end
  
 
  def started_at_than_finished_at_fast_if_invalid
     if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
     end
  end
  
  def self.search(search) #ここでのself.はAttendance.を意味する
    if search
      where(['worked_on LIKE ?', "%#{search}%"])#検索と日付の部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end
  
end
  