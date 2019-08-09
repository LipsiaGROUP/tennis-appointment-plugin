# This migration comes from stecms_coupon (originally 20190530153119)
class ChangeCouponUsableUntilToStecmsCouponPromos < ActiveRecord::Migration
  def change
    rename_column :stecms_coupon_promos, :coupon_usable_untill, :coupon_usable_until
  end
end
