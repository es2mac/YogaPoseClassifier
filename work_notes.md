

## Todo

- Document approach in Google Docs


## High-level approach

Bottom-up approach: Two steps, (1) get keypoints, (2) classify.

Looked around and this seems pretty canonical (keypoints is kind of a well-solved problem).  Training a model to do straight from image to classification is obviously not feasible for me.


## Pose keypoints solutions

- PoseNet, Apple Vision, MoveNet etc.

- PoseNet
    - Simple to get started because of Apple's demo
    - Apple's demo parses the prediction output, which is big help

- Vision's HumanBodyPose is iOS 14, should have a number of advantages
    - Integration, first-party, performance...
    - But, of course, not cross-platform

- MoveNet
    - Seen reports of difficulty converting to CoreML
    - Otherwise needs to add TensorFlow Lite dependency
    - Claims to outperform PoseNet.  Subjectively speaking it does seem to be, quite significantly, based on the [web demo](https://github.com/tensorflow/tfjs-models/tree/master/pose-detection)


## Classification solutions

- Lighter task than pose detection, esp. for stationary poses
- Small-ish neural network, multiclass SVM, k-NN would all work
    - Training a model myself with PyTorch or CreateML is always an option, but data collection and building the pipeline is too much work
    - Apple does have demo with Vision & CreateML: action classification is likely overkill for stationary poses

- For an initial prototype, try simple hand-crafted rules, leave ML approach for later if time permits

- Idea to start: Distance to 3 points, like k-NN with k=1.  Could shift by one of the keypoints, and use cosine similarity to account for scaling-invariance


## Challenges

- The joints results are very noisy
    - Apple demo's default confidence values for PoseNet are set on the high side, can lower to count more points as recognized
    - My hand-crafted classification rules are greatly affected by the noise, and I'd expect a proper ML model to do much better (essentially learning the quirks of the PoseNet keypoints, and learning from negative samples)
    - Better keypoints e.g. MoveNet should help too

- PoseNet's confidence drops significantly for the triangle pose.
    - Other than switching to another model, obvious way to improve is by using the higher accuracy version of PoseNet.
        - 1 file & 1 line change
        - Using 1.00 multiplier does noticeably help, stride 8 vs. 16 noticeably different in running speed but not accuracy
    - MoveNet seems to do much better with this pose (testing on web demo), and more stable overall


## Other notes

- Terminology:
    - "Pose" often refers to just recognizing where the body parts / keypoints are, detecting human figure, often more specifically the collection of keypoints
    - What the pose "is" is commonly referred to as "activity" or "action" recognition / categorization.

- If doing proper classification, want a background class

- Another way to improve the result is to find region of interest first

- Yoga pose names:
    - tree
    - warrior
    - triangle


## References

- [Core ML Models](https://developer.apple.com/machine-learning/models/)

- [Detecting Human Body Poses in an Image](https://developer.apple.com/documentation/coreml/model_integration_samples/detecting_human_body_poses_in_an_image)

- [Detecting Human Body Poses in an Image (with Vision)](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images)

- [MoveNet with TensorFlow Lite](https://github.com/tensorflow/examples/tree/master/lite/examples/pose_estimation/ios)
    - [Blog post](https://blog.tensorflow.org/2021/08/pose-estimation-and-classification-on-edge-devices-with-MoveNet-and-TensorFlow-Lite.html) also describes pose classification

- [Yoga-82 Dataset](https://sites.google.com/view/yoga-82/home)

- WWDC related sessions
    - [Detect Body and Hand Pose with Vision](https://developer.apple.com/videos/play/wwdc2020/10653/)
    - [Detect people, faces, and poses using Vision](https://developer.apple.com/videos/play/wwdc2021/10040/)
        - VNDetectHumanBodyPoseRequest, human rectangle, segmentation

- WWDC tangentially-related sessions
    - [Classify hand poses and actions with Create ML](https://developer.apple.com/videos/play/wwdc2021/10039/)
    - [Build an Action Classifier with Create ML](https://developer.apple.com/videos/play/wwdc2020/10043)
        - Hand pose, CreateML
    - [Explore Computer Vision APIs](https://developer.apple.com/videos/play/wwdc2020/10673)


## Log

- 2/18
    - Received assignment
    - Understanding the problem and possible solutions
        - Collect and study references
    - Generated ideas
        - Tentatively decided to start with PoseNet + hand-crafted rules

- 2/19
    - Continued to survey resources (WWDC)
    - Ran Apple's PoseNet demo
    - Started new app project and migrate/borrow/steal code from PoseNet demo
    - Explored PoseNet's Pose output

- 2/20
    - Implement UI
    - Implement rule-based classification (cosine similarity)
    - Testing, tuning

- 2/21
    - Last tweaks and testing
    - Clean up some notes and code
    - Write in Google Doc


