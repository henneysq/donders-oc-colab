from __future__ import annotations
from itertools import product
import time

from numpy import random
import pandas as pd

from .experiment_manager_base import ExperimentManagerBase
from . import experiment_wm_settings as ewms

from psychopy import core


class WorkingMemoryExperimentManager(ExperimentManagerBase):
    def _make_and_save_experiment_data(self) -> pd.DataFrame:
        # Experiment-specific subroutine that overwrites the
        # ExperimentManagerBase._make_and_save_experiment_data method
        stimuli = ewms.STIMULI
        task_difficulty = ewms.TASK_DIFFICULTY
        repetitions = ewms.REPETITIONS
        blocks = ewms.BLOCKS
        presented_sum_correctness_ = ewms.PRESENTED_SUM_CORRECTNESS

        # Create all unique combinations of stimuli, tasks, and target_congruence.
        # NOTE: combinations are contained in a tuple, making this a list of
        # tuples each with length 3.
        combinations = list(
            product(stimuli, task_difficulty, presented_sum_correctness_)
        )

        # Count the number of unique combinations
        n_combinations = len(combinations)

        # Create a variable to index unique combinations a number of
        # time specified by the number of within-block `repetitions`.
        within_block_combination_indices = list(range(n_combinations)) * repetitions

        # Count number of trials in a block, given unique
        # combinations and repetitions within block
        trials_in_block = n_combinations * repetitions

        # Count total number of trials in experiment
        total_trials = blocks * trials_in_block

        # Make list of trials
        # NOTE: These are 0-indexed
        trial_numbers = list(range(total_trials))

        # Prepare a list to contain conditions of each trial
        conditions_ = [None] * total_trials

        # Prepare a list of block number for each trial
        block_numbers = []

        # Iterate over blocks
        for b in range(blocks):
            # Add block number to the number of trials within block
            block_numbers += [b] * trials_in_block

            # Randomly select the order of trial combinations
            indices_ = random.choice(
                within_block_combination_indices, trials_in_block, replace=False
            )

            # Use the randomised indeces to set the randomised condtions
            # for the given block
            conditions_[b * trials_in_block : (b + 1) * trials_in_block] = [
                combinations[i] for i in indices_
            ]

        # Unpack the combination contents into stimuli, tasks, and congruence
        stimulus_conditions = [c[0] for c in conditions_]
        task_difficulties = [c[1] for c in conditions_]
        presented_sum_correctness = [c[2] for c in conditions_]

        # Prepare empty list of responses
        responses = [None] * total_trials

        # Prepare empty list of reaction times
        reaction_times = [None] * total_trials

        # Prepare empty list of `completed` flags
        completed = [0] * total_trials

        # Create the experiment data table as DataFrame
        experiment_data = pd.DataFrame.from_dict(
            {
                "trial_number": trial_numbers,
                "block_number": block_numbers,
                "stimulus_condition": stimulus_conditions,
                "task_difficulty": task_difficulties,
                "presented_sum_correctness": presented_sum_correctness,
                "response": responses,
                "reaction_time": reaction_times,
                "completed": completed,
            }
        )
        return experiment_data

    def _set_trial_response(self, trial_number: int, response, reaction_time) -> None:
        """Set the response of a given trial

        Args:
            trial_number (int): Trial number to set response for.
            response (_type_): Reponse value.
            reaction_time (_type_): Reaction time.
        """

        self.experiment_data.at[trial_number, "response"] = response
        self.experiment_data.at[trial_number, "reaction_time"] = reaction_time

    def execute_current_trial(
        self,
        stimulus: str,
        presented_sum_correctness: bool,
        instruction_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        if instruction_duration is None:
            instruction_duration = ewms.INSTRUCTION_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = ewms.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = ewms.RESPONSE_TIMEOUT

        values = random.randint(low=1, high=9, size=2)
        true_sum = values[0] + values[1]
        if presented_sum_correctness:
            offset = random.randint(low=1, high=2)
            presented_sum = true_sum + offset * random.choice((-1, 1))
        else:
            presented_sum = true_sum

        # Fixation point
        ewms.FIXATION_MARK.draw()
        ewms.WINDOW.flip()
        core.wait(instruction_duration)

        # Stimulus
        # ledc_left.set_stimuli(stimulus)
        # ledc_right.set_stimuli(stimulus)

        msg = ewms.text_stim(ewms.WINDOW, text=f" {values[0]}\n+{values[1]}")
        msg.draw()
        ewms.WINDOW.flip()
        core.wait(instruction_duration)

        # Fixation point
        ewms.FIXATION_MARK.draw()
        ewms.WINDOW.flip()
        core.wait(random.uniform(*fixation_duration_range))
        # core.wait(instruction_duration)

        msg = ewms.text_stim(ewms.WINDOW, text=f"{presented_sum}")
        msg.draw()
        ewms.WINDOW.flip()

        correct_key = ewms.RESPONSE_KEYS[presented_sum_correctness]

        ewms.KEYBOARD.getKeys()
        return self._get_response_and_reaction_time(
            ewms.KEYBOARD, ewms.WINDOW, correct_key, response_timeout
        )

    def run_experiment(
        self,
        instruction_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        if self.experiment_data is None:
            error_msg = f"Please set `experiment_data` before running experiment"
            raise RuntimeError(error_msg)

        if instruction_duration is None:
            instruction_duration = ewms.INSTRUCTION_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = ewms.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = ewms.RESPONSE_TIMEOUT

        for _ in range(len(self) - self.trial_progress):
            current_trial = self.get_current_trial_data()
            stimulus = current_trial.stimulus_condition
            presented_sum_correctness = current_trial.presented_sum_correctness
            response, reaction_time = self.execute_current_trial(
                presented_sum_correctness=presented_sum_correctness,
                stimulus=stimulus,
                instruction_duration=instruction_duration,
                fixation_duration_range=fixation_duration_range,
                response_timeout=response_timeout,
            )
            self.set_current_trial_response(
                response=response, reaction_time=reaction_time
            )
            self.increment_trial_progress()
            self.save_experiment_data()
