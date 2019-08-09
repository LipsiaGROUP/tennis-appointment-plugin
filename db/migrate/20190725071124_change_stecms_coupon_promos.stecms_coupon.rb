# This migration comes from stecms_coupon (originally 20190530135821)
class ChangeStecmsCouponPromos < ActiveRecord::Migration
  def change
    change_table :stecms_coupon_promos do |t|
      # Set coupons validity detached from promo validity
      t.column :coupon_usable_from,   :datetime
      t.column :coupon_usable_untill, :datetime
      # Set default false because users may want to review the promo before publish
      # Also, app will show only visible coupons. Others will be accessible via QR Code or Manual typing
      t.column :visible, :boolean, null: false, default: false
    end
  end
end
