# task :insert_task_name => :environment do
#   # insert logic, e.g. a cron job for Heroku Scheduler add-on
# end

### USER ONBOARDING - run hourly at 0:00 ###
# task :reminder_to_start_trial => :environment do
#   User.where(created_at: 24.hours.ago..23.hours.ago).each do |user|
#     next if user.paying_customer?
#     UserMailer.reminder_to_start_trial(user).deliver_later
#   end
# end

# enable after improving 'finished_onboarding' logic
# task :offer_setup_assistance => :environment do
#   User.subscribed.where(created_at: 48.hours.ago..47.hours.ago).each do |user|
#     next if user.finished_onboarding?
#     UserMailer.offer_setup_assistance(user).deliver_later
#   end
# end

# enable if Stripe subscriptions exist
task :sync_with_stripe => :environment do
  subscriptions = Stripe::Subscription.list({limit: 100}) # TODO: update when 100+ paying customers exist!
  subscriptions.each do |subscription|
    user = User.find_by(stripe_customer_id: subscription.customer)

    if user.nil?
      AdminMailer.error('User not found for Stripe subscription', "[sync_with_stripe] Customer ID: #{subscription.customer}").deliver_now
      next
    end

    if !['trialing', 'active', 'past_due'].include?(subscription.status)
      user.update(paying_customer: false)
    end
  end
end

# Deletes free Downloads after 5 minutes (TODO: enable once I understand Heroku pricing)
task :delete_free_downloads => :environment do
  Download.where("belongs_to_pro = ?", false).where('created_at <= ?', 5.minutes.ago).destroy_all
end

# Deletes all (pro included) Downloads that are older than 24 hours
task :delete_old_downloads => :environment do
  Download.where('created_at <= ?', 24.hours.ago).destroy_all
end
