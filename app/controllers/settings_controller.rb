class SettingsController < ApplicationController

  def index
    @update_frequency_days = Setting.update_frequency_days
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update(setting_params)
      redirect_to settings_path
    end
  end

private
  def setting_params
    params.require(:setting).permit(:name, :value)
  end
end
