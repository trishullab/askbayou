package edu.rice.cs.caper.askbayou.aat;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.safari.SafariDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class SeleniumAskBayouTest {

    enum Browser {
        CHROME, FIREFOX, SAFARI
    }

    private Browser browser = Browser.CHROME;  // default, change this for different browsers

    private WebDriver driver;

    @Before
    public void setUp() {
        String executablesPath = "/Users/priyaa/Work/askbayou/src/main/resources/artifacts/executables/";

        System.setProperty("webdriver.chrome.driver", executablesPath + "chromedriver_mac64");
        System.setProperty("webdriver.gecko.driver", executablesPath + "geckodriver_mac64");
        System.setProperty("webdriver.safari.driver", "/usr/bin/safaridriver");

        switch (browser) {
            case CHROME:
                driver = new ChromeDriver();
                break;
            case FIREFOX:
                driver = new FirefoxDriver();
                break;
            case SAFARI:
                driver = new SafariDriver();
                break;
        }
        driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
    }

    @After
    public void tearDown() {
        driver.quit();
    }

    @Test
    public void testInfoClick() {
        loadAskBayou();
        WebElement element = driver.findElement(By.id("header"));
        element = element.findElement(By.id("info"));
        element.click();

        String title = driver.getTitle();

        Assert.assertTrue(title.startsWith("How to use Bayou"));
    }

    @Test
    public void testAboutClick() {
        loadAskBayou();
        WebElement element = driver.findElement(By.id("header"));
        element = element.findElement(By.id("about"));
        element.click();

        String title = driver.getTitle();

        Assert.assertTrue(title.startsWith("Bayou: Program synthesis"));
    }

    @Test
    public void testDropDown() {
        loadAskBayou();
        WebElement editorLeftHeader = driver.findElement(By.id("editor-left-header"));
        Select sourceSelect = new Select(editorLeftHeader.findElement(By.id("source-select")));
        List<String> contents = new ArrayList<String>();

        for (int i = 0; i < sourceSelect.getOptions().size(); i++) {
            sourceSelect.selectByIndex(i);
            String content = getLeftEditorContent();
            Assert.assertFalse(contents.contains(content));
            contents.add(content);
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                continue;
            }
        }
    }

    @Test
    public void testSearch() {
        loadAskBayou();

        // select a source
        WebElement editorLeftHeader = driver.findElement(By.id("editor-left-header"));
        WebElement dropDown = editorLeftHeader.findElement(By.id("source-select"));
        Select sourceSelect = new Select(dropDown);
        sourceSelect.selectByIndex(0);

        // click search button and check if spinner is displayed
        WebElement searchButton = editorLeftHeader.findElement(By.id("search-button"));
        WebElement searchSpinner = editorLeftHeader.findElement(By.id("search-spinner"));
        searchButton.click();
        Assert.assertTrue(searchSpinner.isDisplayed());

        // wait till spinner becomes invisible (or until 30s)
        new WebDriverWait(driver, 30).until(
                ExpectedConditions.not(ExpectedConditions.visibilityOf(searchSpinner))
        );

        // check if result contains the word "class"
        String content = getRightEditorContent();
        Assert.assertTrue(content.contains("class"));

        // if there is more than one result, check if left and right buttons work
        WebElement editorRightHeader = driver.findElement(By.id("editor-right-header"));
        WebElement resultsSelector = editorRightHeader.findElement(By.id("results-selector"));
        WebElement resultRightButton = resultsSelector.findElement(By.id("result-right-button"));
        WebElement resultLeftButton = resultsSelector.findElement(By.id("result-left-button"));

        // click right button and left button once, check if content is the same
        if (resultRightButton.isDisplayed() && resultLeftButton.isDisplayed()) {
            resultRightButton.click();
            Assert.assertFalse(getRightEditorContent().equals(content));
            resultLeftButton.click();
            Assert.assertTrue(getRightEditorContent().equals(content));
        }

        // click "Bayou" logo and check if drop down is displayed
        WebElement header = driver.findElement(By.id("header"));
        WebElement logo = header.findElement(By.id("logo"));
        logo.click();
        Assert.assertTrue(dropDown.isDisplayed());
    }

    @Test
    public void testErrorMessage() {
        loadAskBayou();

        WebElement editorLeftHeader = driver.findElement(By.id("editor-left-header"));
        WebElement searchButton = editorLeftHeader.findElement(By.id("search-button"));
        WebElement searchSpinner = editorLeftHeader.findElement(By.id("search-spinner"));

        // click search button and wait till spinner is invisible
        setLeftEditorContent("testing error message");
        searchButton.click();
        new WebDriverWait(driver, 30).until(
                ExpectedConditions.not(ExpectedConditions.visibilityOf(searchSpinner))
        );

        String result = getRightEditorContent();
        Assert.assertTrue(result.equals("Line 1: Syntax error on tokens, delete these tokens"));
    }

    @Test
    public void testRiceCSLink() {
        driver.get("http://www.askbayou.com");

        WebElement riceCSLink = driver.findElement(By.linkText("Department of Computer Science, Rice University"));
        riceCSLink.click();

        String url = driver.getCurrentUrl();
        Assert.assertTrue(url.contains("cs.rice.edu"));
    }

    private String getLeftEditorContent() {
        JavascriptExecutor executor = (JavascriptExecutor) driver;
        return (String) executor.executeScript("return ace.edit(\"editor-left\").getValue()");
    }

    private String getRightEditorContent() {
        JavascriptExecutor executor = (JavascriptExecutor) driver;
        return (String) executor.executeScript("return ace.edit(\"editor-right\").getValue()");
    }

    private void setLeftEditorContent(String content) {
        JavascriptExecutor executor = (JavascriptExecutor) driver;
        executor.executeScript("ace.edit(\"editor-left\").setValue(\"" + content + "\")");
    }

    private void loadAskBayou() {
        // go to askbayou.com and wait till document is ready
        driver.get("http://www.askbayou.com");
        new WebDriverWait(driver, 20).until(
                ExpectedConditions.elementToBeClickable(By.id("editor-left"))
        );
    }
}
