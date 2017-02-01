# This file is part of Moodle - http://moodle.org/
#
# Moodle is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Moodle is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Moodle.  If not, see <http://www.gnu.org/licenses/>.
#
# Tests for page module.
#
# @package    theme_snap
# @author     Guillermo Alvarez
# @copyright  2016 Blackboard Ltd
# @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later


@theme @theme_snap
Feature: Open page module inline
  As any user
  I need to view page modules inline and have auto completion tracking updated.

  Background:
    Given the following config values are set as admin:
      | enablecompletion   | 1    |
      | enableavailability | 1    |
      | theme              | snap |
    And the following "users" exist:
      | username | firstname | lastname | email                |
      | student1 | Student   | 1        | student1@example.com |
    And the following "course enrolments" exist:
      | user  | course               | role    |
      | admin | Acceptance test site | teacher |

  @javascript
  Scenario: Page mod is created and opened inline at the front page.
     Given the following "activities" exist:
       | activity | course               | idnumber | name       | intro        | content       | completion | completionview | section |
       | page     | Acceptance test site | page1    | Test page1 | Test page 1  | page content1 | 0          | 0              | 1       |
     And I log in as "admin"
     And I am on site homepage
     And I should not see "page content1"
     And I follow "Read more&nbsp;»"
     And I wait until ".pagemod-content[data-content-loaded=\"1\"]" "css_element" is visible
     # The above step basically waits for the page content to load up.
     And I should see "page content1"


  @javascript
  Scenario: Page mod completion updates on read more and affects availability for other modules at the front page.
    Given the following "activities" exist:
      | activity | course               | idnumber  | name              | intro                 | content                 | completion | completionview | section |
      | page     | Acceptance test site | pagec     | Page completion   | Page completion intro | Page completion content | 2          | 1              | 1       |
      | page     | Acceptance test site | pager     | Page restricted   | Page restricted intro | Page restricted content | 0          | 0              | 1       |
    And the following "activities" exist:
      | activity | course               | idnumber     | name            | section |
      | assign   | Acceptance test site | assigntest   | Assignment Test | 0       |
    And completion tracking is "Enabled" for course "Acceptance test site"
   Then I log in as "admin" (theme_snap)
    And I am on site homepage
    # Restrict the second page module to only be accessible after the first page module is marked complete.
    And I restrict course asset "Page restricted" by completion of "Page completion"
    And I log out (theme_snap)
    And I log in as "student1" (theme_snap)
    And I am on site homepage
    Then I should not see "Page restricted intro"
    And I should see availability info "Not available unless: The activity Page completion is marked complete"
    And I follow visible link "Read more&nbsp;»"
    And I wait until ".pagemod-content[data-content-loaded=\"1\"]" "css_element" is visible
    # The above step basically waits for the page module content to load up.
    Then I should see "Page completion content"
    And I should not see availability info "Not available unless: The activity Page completion is marked complete"
    And I should see "Page restricted"
    And I follow visible link "Read more&nbsp;»"
    Then I should see " Page restricted content"
