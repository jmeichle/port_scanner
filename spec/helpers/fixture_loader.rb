module FixtureLoaderHelper
  FIXTURE_PATH = File.join(File.dirname(__FILE__), '../fixtures')

  def fixture_path(*parts)
    File.join(*parts.unshift(FIXTURE_PATH))
  end

  def load_fixture(name)
    File.read("#{fixture_path}/#{name}")
  end
end
